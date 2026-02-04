import json
# main.py
from kivymd.uix.list import MDListItem, MDListItemHeadlineText, MDListItemSupportingText, MDListItemLeadingIcon, MDListItemTrailingIcon



default_dict = {
   "id": -1,
   "Tipo": "False",
   "Ejercicio": "",
   "Peso": "0 kg",
   "Repeticiones": 0,
   "Series": 0
}

def get_data_json(file:str="datos.json"):
    with open(file, "r") as file:
       data = json.load(file)
    return data


def save_data_json(file:str="datos.json", new_data:dict=default_dict):
   with open(file, "r") as file:
      data = json.load(file)
   ids = [dat.get("id") for dat in data if type(dat.get("id")) == int]
   id = min([i for i in range(1, max(ids)+2) if i not in ids])
   print(id)
   new_data["id"] = id
   data.append(new_data)
   with open("datos.json", "w", encoding="utf-8") as f:
      json.dump(data, f, indent=4)


def update_data_json(file:str="datos.json", new_data:dict=default_dict, value_id:int=-1):
   with open(file, "r") as file:
      data = json.load(file)
   data = [dat for dat in data if dat.get("id") != value_id]
   if not new_data.get("id"):
      ids = [dat.get("id") for dat in data if type(dat.get("id")) == int]
      id = min([i for i in range(1, max(ids)+2) if i not in ids])
      new_data["id"] = id
   data.append(new_data)
   with open("datos.json", "w", encoding="utf-8") as f:
      json.dump(data, f, indent=4)


def del_data_json(file:str="datos.json", value_id:int=-1):
   with open(file, "r") as file:
      data = json.load(file)

   data = [dat for dat in data if dat.get("id") != value_id]
   with open("datos.json", "w", encoding="utf-8") as f:
      json.dump(data, f, indent=4)

def add_item_list(instance, lista_widget, tipo_ejercicio):
    lista_widget.clear_widgets()  # Limpiar si hay algo
    data_json = get_data_json()
    data_ejercicio = [data for data in data_json if data.get("Tipo") == tipo_ejercicio]
    data_ejercicio = sorted(data_ejercicio, key=lambda x: x['Ejercicio'])
    for persona in data_ejercicio:

        # Crear cada elemento de la lista
        item = MDListItem(
            MDListItemHeadlineText(
                text=f"[b]{persona['Ejercicio']}[/b]",
                theme_text_color="Custom",
                text_color=instance.theme_cls.primaryColor,
            ),
            MDListItemSupportingText(
                text=f"Peso: {persona['Peso']} | Rep: {persona['Repeticiones']} | Series: {persona['Series']}"
            ),
            # Opcional: agregar icono
            MDListItemLeadingIcon(
                
                icon="account"
            ),
            on_release=lambda x, p=persona: instance.edit_data(p)#instance.seleccionar_persona(p)
        )
        lista_widget.add_widget(item)