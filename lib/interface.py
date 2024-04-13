from typing import TypeVar

T = TypeVar("T")

def print_numbered_list(items):
    i = 1
    for item in items:
        print(f"{i}. {item}")
        i += 1

def get_all_possible_selections(items:list[T], search_string:str)->list[T]:
    matching_items = []
    search_string = search_string.lower()
    i = 1
    for item in items:
        item_str = str(item).lower()
        if search_string == str(i) or search_string == item_str:
            return [item]
        elif item_str.find(search_string) > -1:
            matching_items.append(item)
        i += 1
    return matching_items

def get_list_selection(items: list[T], display_items: list[str] = None, msg: str = None) -> T|None:

    if display_items is None:
        display_items = [str(item) for item in items]
    if msg is None:
        msg = "Please choose an item: "

    print()
    print_numbered_list(display_items)

    choice:T = None
    
    while choice == None:
        user_input = input(msg)
        
        if user_input.strip() == "":
            return None
        if user_input.isdigit() and (int(user_input) < 1 or int(user_input) > len(items)):
            print(f"'{user_input}' is not a valid index!")
            continue

        matching_items = get_all_possible_selections(display_items, user_input)
        if len(matching_items) == 0:
            print(f"'{user_input}' is not a valid item!")
        elif len(matching_items) > 1:
            print(f"'{user_input}' matches the following items [{', '.join(matching_items)}] Please be more specific!")
        else:
            choice = matching_items[0]
    
    return choice