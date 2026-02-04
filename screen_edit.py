from kivymd.uix.screen import MDScreen
from functions import save_data_json, update_data_json, del_data_json
from kivymd.uix.menu import MDDropdownMenu
from kivy.properties import ObjectProperty


class ScreenEditData(MDScreen):
    data = ObjectProperty(None)
    previous_screen = ObjectProperty(None)

    def on_enter(self):
        self.ids['buton_text_dropdown'].text = self.data.get("Tipo")
        self.ids.adddata_textfield_ejercicio.text = self.data.get("Ejercicio")
        self.ids.adddata_textfield_peso.text = self.data.get("Peso")
        self.ids.adddata_textfield_repeticiones.text = str(self.data.get("Repeticiones"))
        self.ids.adddata_textfield_series.text = str(self.data.get("Series"))

    
    def menu_open(self):
        menu_items = [
            {
                "text": "Biceps",
                "on_release": lambda x=f"Biceps": self.seleccionar_item(x),
            },
            {
                "text": "Pectoral",
                "on_release": lambda x=f"Pectoral": self.seleccionar_item(x),
            },
                        {
                "text": "Espalda",
                "on_release": lambda x=f"Espalda": self.seleccionar_item(x),
            },
            {
                "text": "Triceps",
                "on_release": lambda x=f"Triceps": self.seleccionar_item(x),
            },
            {
                "text": "Hombros",
                "on_release": lambda x=f"Hombros": self.seleccionar_item(x),
            }

            
        ]
        
        # Crear el menú
        self.menu = MDDropdownMenu(
            caller=self.ids.boton_menu,
            items=menu_items
        )
        self.menu.open()

    def seleccionar_item(self, texto_item):
        self.ids['buton_text_dropdown'].text = texto_item
        self.menu.dismiss()


    def menu_callback(self, text_item):
        print(text_item)
    
    def save_data(self):
        value_id = self.data.get("id")
        self.tipo = self.ids['buton_text_dropdown'].text
        self.ejercicio = self.ids.adddata_textfield_ejercicio.text
        self.peso = self.ids.adddata_textfield_peso.text
        self.repeticiones = self.ids.adddata_textfield_repeticiones.text
        self.series = self.ids.adddata_textfield_series.text

        data = {
            "Tipo": self.tipo,
            "Ejercicio": self.ejercicio,
            "Peso": self.peso,
            "Repeticiones": int(self.repeticiones),
            "Series": int(self.series)
            }
        if self.tipo not in ["Biceps", "Pectoral", "Espalda", "Triceps", "Hombros"]:
            print("not in category")
            return False
        
        update_data_json(new_data=data, value_id=value_id)
        self.parent.current = self.previous_screen

    def clear_textbox(self):

        self.ids.adddata_textfield_ejercicio.text = ""
        self.ids.adddata_textfield_peso.text = ""
        self.ids.adddata_textfield_repeticiones.text = ""
        self.ids.adddata_textfield_series.text = ""

    def delete_data(self):
        value_id = self.data.get("id")
        del_data_json(value_id=value_id)
        self.parent.current = self.previous_screen
    
    def return_screen(self):
        self.parent.current = self.previous_screen