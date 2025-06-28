#!/usr/bin/env python3
"""
Lua API Documentation Generator for MKDocs Material
Generates markdown API reference files from Lua source code.
Just specify the names you want documented - extracts all info automatically.
"""

#DONE: Extract class/type inheritance
#TODO: Check for "Expose(function.name" to mention it's exposed
#TODO: Extract summary from properties
#TODO: Extract deprecated
#TODO: Extract operator overloads

import os
import re
import argparse
import json
import yaml
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Any, Set, cast
from dataclasses import dataclass, field
import traceback

@dataclass
class Parameter:
    name: str
    type_: str
    types: List[str] = field(default_factory=list)
    description: str = ""
    optional: bool = False

@dataclass
class Return:
    type_: str
    types: List[str] = field(default_factory=list)
    description: str = ""

@dataclass
class GlobalVar:
    name: str
    value: str
    description: str = ""

@dataclass
class Property:
    name: str
    description: str
    default_value: str = ""
    type_: str = ""
    example_usage: str = ""

@dataclass
class Method:
    name: str
    description: str
    parameters: list[Parameter] = field(default_factory=list)
    returns: list[Return] = field(default_factory=list)
    is_method: bool = True
    class_name: str = ""
    exposed_name: str = ""

@dataclass
class TypeField:
    name: str
    type_: str
    description: str
    optional: bool = False

@dataclass
class TypeDef:
    name: str
    description: str
    fields: list[TypeField] = field(default_factory=list)
    inherits: list[str] = field(default_factory=list)

@dataclass
class AliasValue:
    type_: str
    description: str = ""

@dataclass
class Alias:
    name: str
    description: str
    types: list[AliasValue] = field(default_factory=list)

@dataclass
class DocumentationData:
    global_vars: list[GlobalVar] = field(default_factory=list)
    properties: list[Property] = field(default_factory=list)
    methods: list[Method] = field(default_factory=list)
    functions: list[Method] = field(default_factory=list)
    types: list[TypeDef] = field(default_factory=list)
    aliases: list[Alias] = field(default_factory=list)
    module_description: str = ""

class ConfigManager:
    """Manages simple name-based configuration."""
    
    def __init__(self, config_file: Optional[str] = None):
        self.config = {}
        if config_file and os.path.exists(config_file):
            # Support both JSON and YAML
            with open(config_file, 'r') as f:
                if config_file.endswith('.yaml') or config_file.endswith('.yml'):
                    self.config = yaml.safe_load(f)
                else:
                    self.config = json.load(f)
    
    # Old type before replacements: Dict[str, List[str]]
    def get_items_for_file(self, file_path: str) -> Dict[str, List[str]]:
        """Get items to document for a specific file."""
        # Try different path formats
        rel_path = str(Path(file_path).as_posix())
        
        # Remove common prefixes
        for prefix in ['scripts/vscripts/alyxlib/', 'scripts/', 'vscripts/', 'alyxlib/']:
            if rel_path.startswith(prefix):
                rel_path = rel_path[len(prefix):]
                break
        
        # Remove .lua extension
        if rel_path.endswith('.lua'):
            rel_path = rel_path[:-4]
        
        # Look for this file in config
        return self.config.get(rel_path, {})

def split_types(type_str):
    parts = []
    current = []
    depth = 0
    for c in type_str:
        if c == '(':
            depth += 1
        elif c == ')':
            depth -= 1
        elif c == '|' and depth == 0:
            parts.append(''.join(current).strip())
            current = []
            continue
        current.append(c)
    if current:
        parts.append(''.join(current).strip())
    return parts

def clean_comment(comment: str) -> str:
    """Clean up comment text by removing leading/trailing whitespace and special characters."""
    return comment.strip().strip('#').strip()

def clean_type(type_str: str) -> str:
    """Clean up a type string by removing backticks and extra whitespace."""
    return type_str.strip().strip('`').strip()

def split_type_string(type_str: str) -> list[str]:
    """Split a type string into individual types, handling nested types."""
    return [clean_type(param_t) for param_t in split_types(type_str)]

def apply_replacements(content: str, replacements: list[dict[str, str]]) -> str:
    """Apply replacements to the content."""
    if not replacements:
        return content

    for replacement in replacements:
        # if len(replacement) != 1:
        #     raise ValueError("Each replacement should have exactly one key-value pair")
        for to_replace, with_replacement in replacement.items():
            content = content.replace(to_replace, with_replacement)
    return content

class LuaDocParser:
    def __init__(self, config_manager: Optional[ConfigManager] = None):
        self.config = config_manager or ConfigManager()
        
    def parse_file(self, file_path: str) -> DocumentationData:
        """Parse a Lua file and extract documentation for specified items."""
        doc_data = DocumentationData()
        
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            lines = content.splitlines()
        
        # Get what to document from config
        items_config = self.config.get_items_for_file(file_path)

        replacements = cast(List[Dict[str, str]], items_config.get('replacements', []))
        # content = apply_replacements(content, replacements)
        # print(replacements)
        # for replacement in replacements:
        #     print(replacement)
        #     # Should only have one key-value pair
        #     for to_replace, with_replacement in replacement.items():
        #         print(f"Replacing '{to_replace}' with '{with_replacement}' in {file_path}")
        #         # Replace all occurrences of the replacement string with an empty string
        #         content = content.replace(to_replace, with_replacement)
        
        # lines = content.splitlines()
        
        # Parse global variables
        for var_name in items_config.get('globals', []):
            value = self._find_variable_value(content, var_name)
            doc_data.global_vars.append(GlobalVar(
                name=var_name,
                value=value,
                description=""
            ))
        
        # Parse properties/fields  
        for field_name in items_config.get('fields', []):
            value = self._find_variable_value(content, field_name)
            # Extract just the property name (after the last dot)
            prop_name = field_name.split('.')[-1] if '.' in field_name else field_name

            field_name = apply_replacements(field_name, replacements)
            prop_name = apply_replacements(prop_name, replacements)
            
            doc_data.properties.append(Property(
                name=prop_name,
                description="",
                default_value=value,
                example_usage=f"{field_name} = value"
            ))
        
        # Parse types
        for type_name in items_config.get('types', []):
            type_def = self._extract_type_definition(content, lines, type_name)
            if type_def:
                doc_data.types.append(type_def)
        
        # Parse aliases
        for alias_name in items_config.get('aliases', []):
            alias_def = self._extract_alias_definition(content, lines, alias_name)
            if alias_def:
                alias_def.name = apply_replacements(alias_def.name, replacements)
                doc_data.aliases.append(alias_def)
        
        # Parse methods and functions
        method_names = items_config.get('methods', [])
        function_names = items_config.get('functions', [])
        
        all_function_names = method_names + function_names
        
        for func_name in all_function_names:
            method = self._extract_function_definition(content, lines, func_name)
            if method:
                method.name = apply_replacements(method.name, replacements)
                method.class_name = apply_replacements(method.class_name, replacements)
                if func_name in method_names:
                    method.is_method = True
                    doc_data.methods.append(method)
                else:
                    method.is_method = False
                    doc_data.functions.append(method)
        
        return doc_data
    
    def _find_variable_value(self, content: str, var_name: str) -> str:
        """Find the value of a variable in the code."""
        # Escape dots for regex
        escaped_name = re.escape(var_name)
        
        patterns = [
            rf'{escaped_name}\s*=\s*([^=\r\n]+)',
            rf'local\s+{escaped_name}\s*=\s*([^=\r\n]+)',
        ]
        
        for pattern in patterns:
            match = re.search(pattern, content)
            if match:
                value = match.group(1).strip()
                # Clean up the value
                if value.endswith(','):
                    value = value[:-1].strip()
                # Remove comments
                if '--' in value:
                    value = value.split('--')[0].strip()
                return value
        
        return ""
    
    def _looks_like_example_code(self, content: str) -> bool:
        """Check if the content looks like example code."""
        # Simple heuristic: check for function definitions or variable assignments
        # return bool(re.search(r'\bfunction\s+\w+\s*\(.*\)\s*{', content) or
        #             re.search(r'\b\w+\s*=\s*[^=]+', content) or
        #             re.search(r'\blocal\s+\w+\s*=\s*[^=]+', content))
        possible_code = content
        if possible_code.startswith('---'): possible_code = possible_code.strip()[3:]
        # Treat indented without list symbols as code
        if possible_code.startswith('    ') or possible_code.startswith('\t'):
            if not possible_code.strip().startswith(('-', '>', '*', '+')):
                return True
        
        return False

    
    # def parse_param_types(self, param_type: str) -> List[str]:
    #     """Parse a parameter type string int a list of types, with whitespace and backticks removed."""
    #     def clean(t: str) -> str:
    #         return t.strip().strip('`')
    
    def _extract_function_definition(self, content: str, lines: List[str], func_name: str) -> Optional[Method]:
        """Extract function definition and its documentation."""
        
        # Handle method vs function notation
        if ':' in func_name:
            # Method: Class:method
            class_name, method_name = func_name.split(':', 1)
            search_pattern = rf'function\s+{re.escape(func_name)}\s*\('
            is_method = True
        elif '.' in func_name:
            # Function: Module.function  
            parts = func_name.split('.')
            class_name = '.'.join(parts[:-1])
            method_name = parts[-1]
            search_pattern = rf'function\s+{re.escape(func_name)}\s*\('
            is_method = False
        else:
            # Global function
            class_name = ""
            method_name = func_name
            search_pattern = rf'function\s+{re.escape(func_name)}\s*\('
            is_method = False
        
        # Find the function definition
        func_match = re.search(search_pattern, content)
        if not func_match:
            return None
        
        # Find which line the function is on
        func_line_start = content[:func_match.start()].count('\n')
        
        # Extract the full function signature
        func_line = lines[func_line_start]
        params_match = re.search(r'function\s+[^(]+\(([^)]*)\)', func_line)
        params_str = params_match.group(1) if params_match else ""
        
        # Look for preceding comment block
        comment_lines: list[str] = []
        i = func_line_start - 1
        while i >= 0 and lines[i].strip().startswith('---'):
            comment_lines.insert(0, lines[i].strip()[3:])
            i -= 1
        
        # Parse the comment block
        description_lines: list[str] = []
        params: list[Parameter] = []
        returns = []
        exposed_name: str = ''
        
        for line in comment_lines:
            if line.startswith('@param'):
                match = re.match(r'@param\s+(\w+)(\?)?\s+(\S+)(?:\s+(.+))?', line)
                if match:
                    param_name, is_optional, param_type, param_desc = match.groups()
                    params.append(Parameter(
                        name=param_name,
                        type_=param_type,
                        types=split_type_string(param_type),
                        description=clean_comment(param_desc or ''),
                        optional=(is_optional is not None)
                    ))
            elif line.startswith('|'):
                # Handle extended parameters for the previous param
                if params:
                    match = re.match(r'\|\s*(\S+)(?:\s+(.+))?', line)
                    if match:
                        param_type, param_desc = match.groups()
                        last_param = params[-1]
                        last_param.types.extend(split_type_string(param_type))
                    
            elif line.startswith('@return'):
                match = re.match(r'@return\s+(\S+)(?:\s+(.+))?', line)
                if match:
                    return_type, return_desc = match.groups()
                    returns.append(Return(
                        type_=return_type,
                        types=split_type_string(return_type),
                        description=clean_comment(return_desc or '')
                    ))
            elif line.startswith("@exposed"):
                match = re.match(r'@exposed\s+(\w+)\s*', line)
                if match:
                    exposed_name = match.group(1)
            elif not line.startswith('@'):
                if description_lines and description_lines[-1].strip() == '' and self._looks_like_example_code(line):
                    description_lines.append(f"`{line.strip()}`")
                else:
                    description_lines.append(line.strip())
        
        # If no parameters documented but function has parameters, extract from signature
        if not params and params_str.strip():
            # print(f"NO PARAMS {func_name}")
            param_names = [p.strip() for p in params_str.split(',') if p.strip()]
            for param_name in param_names:
                params.append(Parameter(
                    name=param_name,
                    type_='unknown',
                    types=['unknown'],
                    description=''
                ))
        
        return Method(
            name=method_name,
            description='\n'.join(description_lines).strip(),
            parameters=params,
            returns=returns,
            is_method=is_method,
            class_name=class_name,
            exposed_name=exposed_name
        )
    
    def _extract_type_definition(self, content: str, lines: List[str], type_name: str) -> Optional[TypeDef]:
        """Extract type definition from comments."""
        
        # Look for @class annotation
        class_pattern = rf'@class\s+{re.escape(type_name)}'
        class_match = re.search(class_pattern, content)
        if not class_match:
            return None
        
        # Find which line the @class is on
        class_line_start = content[:class_match.start()].count('\n')
        
        # Collect all comment lines around this @class
        comment_lines = []
        description_lines = []
        fields = []
        inherits = []
        
        # Look backwards and forwards for related comment lines
        i = class_line_start
        while i < len(lines) and lines[i].strip().startswith('---'):
            line_content = lines[i].strip()[3:].strip()
            
            if line_content.startswith('@class'):
                # Extract inheritence
                match = re.match(r'@class\s+\w+\s*:\s*(\w+(?:\s*,\s*\w+)*)', line_content)
                if match:
                    [inherit_str] = match.groups()
                    inherits = inherit_str.split(',')
                pass
            elif line_content.startswith('@field'):
                match = re.match(r'@field\s+(\w+)(\?)?\s+(\S+)(?:\s+(.+))?', line_content)
                if match:
                    field_name, is_optional, field_type, field_desc = match.groups()
                    fields.append(TypeField(
                        name=field_name,
                        type_=field_type,
                        description=clean_comment(field_desc or ''),
                        optional=(is_optional is not None)
                    ))
            elif not line_content.startswith('@'):
                description_lines.append(line_content)
            
            i += 1
        
        # Also check lines before @class
        i = class_line_start - 1
        while i >= 0 and lines[i].strip().startswith('---'):
            line_content = lines[i].strip()[3:].strip()
            if not line_content.startswith('@'):
                description_lines.insert(0, line_content)
            i -= 1
        
        return TypeDef(
            name=type_name,
            description='\n'.join(description_lines).strip(),
            fields=fields,
            inherits=inherits
        )
    
    def _extract_alias_definition(self, content: str, lines: List[str], alias_name: str) -> Optional[Alias]:
        """Extract alias definition from comments."""
        
        # Look for @alias annotation
        alias_pattern = rf'@alias\s+{re.escape(alias_name)}'
        alias_match = re.search(alias_pattern, content)
        if not alias_match:
            return None
        
        
        # Find which line the @alias is on
        alias_line_start = content[:alias_match.start()].count('\n')

        # Collect all comment lines around this @alias
        comment_lines = []
        description_lines = []
        values: list[AliasValue] = []
        
        # Look forwards for related comment lines
        i = alias_line_start
        while i < len(lines) and lines[i].strip().startswith('---'):
            line_content = lines[i].strip()[3:].strip()
            if line_content.startswith('@alias'):
                # Extract the types on the same line as @alias
                match = re.match(r'@alias\s+\S+\s+(.+)', line_content)
                if match:
                    type_str = match.group(1)
                    type_parts = split_type_string(type_str)
                    for part in type_parts:
                        values.append(AliasValue(
                            type_=part,
                            description=""
                        ))
            elif line_content.startswith('|'):
                # Handle extended types for the current alias
                match = re.match(r'\|\s*(\S+)(?:\s+(.+))?', line_content)
                if match:
                    type_str, type_desc = match.groups()
                    values.append(AliasValue(
                        type_=clean_type(type_str),
                        description=clean_comment(type_desc or '')
                    ))
            elif not line_content.startswith('@'):
                description_lines.append(line_content)
            i += 1
        
        # Also check lines before @alias
        i = alias_line_start - 1
        while i >= 0 and lines[i].strip().startswith('---'):
            line_content = lines[i].strip()[3:].strip()
            if not line_content.startswith('@'):
                description_lines.insert(0, line_content)
            i -= 1
        
        return Alias(
            name=alias_name,
            description='\n'.join(description_lines).strip(),
            types=values
        )

class MarkdownGenerator:
    def generate(self, doc_data: DocumentationData, module_name: str = "", rel_path: Optional[Path] = None) -> str:
        """Generate markdown documentation from parsed data."""
        sections = []
        
        if module_name:
            # sections.append(f"> scripts/vscripts/alyxlib/{module_name}")
            path = str(rel_path).removesuffix(".lua")
            sections.append(f"# {' '.join([name.capitalize() for name in re.split(r"[\\/]", path)])}")
            sections.append("")
        
        if rel_path:
            sections.append(f"> scripts/vscripts/alyxlib/{rel_path.as_posix()}")
            sections.append("")
        
        # Global variables
        if doc_data.global_vars:
            sections.append("## Global variables")
            sections.append("")
            
            # Check if they look like related constants
            if self._looks_like_constants(doc_data.global_vars):
                prefix = self._find_common_prefix([var.name for var in doc_data.global_vars])
                if prefix:
                    title = prefix.replace('_', ' ').replace('Input', '').strip()
                    if title:
                        sections.append(f"| {title} |  |")
                    else:
                        sections.append("| Name | Value |")
                else:
                    sections.append("| Name | Value |")
            else:
                sections.append("| Name | Value |")
            
            sections.append("| -------------------- | ----- |")
            for var in doc_data.global_vars:
                sections.append(f"| `{var.name}` | `{var.value}` |")
            sections.append("")
        
        # Properties
        if doc_data.properties:
            sections.append("## Properties")
            sections.append("")
            for prop in doc_data.properties:
                sections.append(f"### {prop.name}")
                if prop.description:
                    sections.append(prop.description)
                sections.append("")
                
                sections.append("```lua")
                sections.append(prop.example_usage)
                sections.append("```")
                sections.append("")
                
                if prop.default_value:
                    sections.append("**Default value**")
                    sections.append(f"  `{prop.default_value}`")
                    sections.append("")
        
        # Methods
        if doc_data.methods:
            sections.append("## Methods")
            sections.append("")
            for method in doc_data.methods:
                # print(f"Method: {method.name}")
                sections.extend(self._generate_method_section(method))
        
        # Functions
        if doc_data.functions:
            sections.append("## Functions")
            sections.append("")
            for func in doc_data.functions:
                # print(func.name)
                # if func.name == "RegisterAlyxLibAddon":
                #     print(func.parameters)
                sections.extend(self._generate_method_section(func))
        
        # Types
        if doc_data.types:
            sections.append("## Types")
            sections.append("")
            for type_def in doc_data.types:
                sections.append(f"### {type_def.name}")
                sections.append("")
                if type_def.inherits:
                    sections.append(f"> **Inherits from:** {', '.join([f"`{inherit}`" for inherit in type_def.inherits])}")
                    sections.append("")
                if type_def.description:
                    sections.append(type_def.description)
                    sections.append("")
                
                if type_def.fields:
                    sections.append("| Field | Type | Description |")
                    sections.append("| ---- | ---- | ----------- |")
                    for field in type_def.fields:
                        sections.append(f"| {field.name}{'?' if field.optional else ''} | `{field.type_}` | {field.description} |")
                    sections.append("")
        
        # Aliases
        if doc_data.aliases:
            sections.append("## Aliases")
            sections.append("")
            for alias_def in doc_data.aliases:
                sections.append(f"### {alias_def.name}")
                sections.append("")
                if alias_def.description:
                    sections.append(alias_def.description)
                    sections.append("")
                
                if alias_def.types:
                    sections.append("| Value | Description |")
                    sections.append("| ----- | ----------- |")
                    for value in alias_def.types:
                        sections.append(f"| `{value.type_}` | {value.description} |")
                    sections.append("")
        
        return '\n'.join(sections)
    
    def _looks_like_constants(self, global_vars: List[GlobalVar]) -> bool:
        """Check if global variables look like a set of related constants."""
        if len(global_vars) < 2:
            return False
        
        names = [var.name for var in global_vars]
        prefix = self._find_common_prefix(names)
        return len(prefix) > 3
    
    def _find_common_prefix(self, strings: List[str]) -> str:
        """Find the common prefix of a list of strings."""
        if not strings:
            return ""
        
        prefix = strings[0]
        for s in strings[1:]:
            while prefix and not s.startswith(prefix):
                prefix = prefix[:-1]
        
        return prefix
    
    def _generate_method_section(self, method: Method) -> List[str]:
        """Generate markdown section for a method or function."""
        sections = []
        
        sections.append(f"### {method.name}")
        sections.append("")
        if method.description:
            sections.append(method.description)
            sections.append("")
        
        # Code example
        sections.append("```lua")
        if method.is_method and method.class_name:
            param_names = [p.name for p in method.parameters]
            sections.append(f"{method.class_name}:{method.name}({', '.join(param_names)})")
        elif method.class_name:
            param_names = [p.name for p in method.parameters]
            sections.append(f"{method.class_name}.{method.name}({', '.join(param_names)})")
        else:
            param_names = [p.name for p in method.parameters]
            sections.append(f"{method.name}({', '.join(param_names)})")
        sections.append("```")
        sections.append("")
        
        # Parameters
        if method.parameters:
            sections.append("**Parameters**")
            sections.append("")
            for param in method.parameters:
                optional_str = " *(optional)*" if param.optional else ""
                sections.append(f"- **`{param.name}`**{optional_str}  ")
                if param.type_ and param.type_ != 'unknown':
                    sections.append(f"  {', '.join([f"`{t}`" for t in param.types])}  ")
                if param.description:
                    sections.append(f"  {param.description}")
            sections.append("")
        
        # Returns
        if method.returns:
            sections.append("**Returns**")
            for ret in method.returns:
                sections.append(f"- **`{ret.type_}`**")
                if ret.description:
                    sections.append(f"  {ret.description}")
            sections.append("")
        
        if method.exposed_name:
            sections.append(f"!!! exposed \"[Exposed](PUT LINK HERE) To Hammer as `{method.exposed_name}`\"")
            sections.append("")
        
        return sections

def create_example_config(output_file: str, format_type: str = 'yaml'):
    """Create an example configuration file."""
    
    if format_type == 'yaml':
        example_content = """# Documentation configuration
# Specify what to extract from each file

controls/input:
  methods:
    - Input:GetButtonDescription
  fields:
    - Input.MultiplePressInterval
  globals:
    - InputHandBoth
    - InputHandLeft
    - InputHandRight
    - InputHandPrimary
    - InputHandSecondary
  types:
    - InputPressCallback

# Another file example
# utils/math:
#   functions:
#     - CalculateDistance
#     - NormalizeVector
#   globals:
#     - PI
#     - TAU
"""
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(example_content)
    else:
        example_config = {
            "controls/input": {
                "methods": [
                    "Input:GetButtonDescription"
                ],
                "fields": [
                    "Input.MultiplePressInterval"
                ],
                "globals": [
                    "InputHandBoth",
                    "InputHandLeft", 
                    "InputHandRight",
                    "InputHandPrimary",
                    "InputHandSecondary"
                ],
                "types": [
                    "InputPressCallback"
                ]
            }
        }
        
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(example_config, f, indent=2)
    
    print(f"Example configuration created: {output_file}")

def main():
    parser = argparse.ArgumentParser(description='Generate Markdown API documentation from Lua files')
    parser.add_argument('input_dir', help='Input directory containing Lua files')
    parser.add_argument('output_dir', help='Output directory for markdown files')
    parser.add_argument('--config', '-c', help='Configuration file (JSON or YAML) specifying what to document')
    parser.add_argument('--create-config', help='Create an example configuration file')
    parser.add_argument('--config-format', choices=['json', 'yaml'], default='yaml',
                       help='Format for created config file')
    parser.add_argument('--script-prefix', default='scripts/vscripts/alyxlib/', 
                       help='Prefix to remove from input paths')
    parser.add_argument('--recursive', '-r', action='store_true',
                       help='Process files recursively')
    
    args = parser.parse_args()
    
    if args.create_config:
        create_example_config(args.create_config, args.config_format)
        return 0
    
    input_path = Path(args.input_dir)
    output_path = Path(args.output_dir)
    
    if not input_path.exists():
        print(f"Error: Input directory '{input_path}' does not exist")
        return 1
    
    if not args.config:
        print("Error: Configuration file is required. Use --create-config to generate an example.")
        return 1
    
    if not os.path.exists(args.config):
        print(f"Error: Configuration file '{args.config}' does not exist")
        return 1
    
    # Create output directory if it doesn't exist
    output_path.mkdir(parents=True, exist_ok=True)
    
    config_manager = ConfigManager(args.config)
    parser_obj = LuaDocParser(config_manager)
    generator = MarkdownGenerator()
    
    # Get all files mentioned in config
    documented_files = set()
    for file_key in config_manager.config.keys():
        # Convert config key back to full path
        full_path = input_path / (file_key + '.lua')
        if full_path.exists():
            documented_files.add(full_path)
        else:
            print(f"Warning: File not found for config key '{file_key}': {full_path}")
    
    if not documented_files:
        print("No files found to document based on configuration")
        return 1
    
    for lua_file in documented_files:
        print(f"Processing {lua_file}")
        
        try:
            doc_data = parser_obj.parse_file(str(lua_file))
            
            # Calculate relative path and output path
            rel_path = lua_file.relative_to(input_path)
            
            # Remove script prefix if present
            rel_path_str = str(rel_path)
            if args.script_prefix and rel_path_str.startswith(args.script_prefix):
                rel_path_str = rel_path_str[len(args.script_prefix):]
                rel_path = Path(rel_path_str)
            
            # Change extension to .md
            output_file = output_path / rel_path.with_suffix('.md')
            
            # Create output directory structure
            output_file.parent.mkdir(parents=True, exist_ok=True)
            
            # Generate markdown
            module_name = rel_path.stem
            markdown_content = generator.generate(doc_data, module_name, rel_path)
            
            # Write output file
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(markdown_content)
            
            print(f"Generated {output_file}")
            
        except Exception as e:
            print(f"Error processing {lua_file}: {e}")
            traceback.print_exc()
            continue
    
    print(f"Documentation generation complete. {len(documented_files)} files processed.")
    return 0

if __name__ == '__main__':
    exit(main())