from kivymd.uix.screen import MDScreen
from functions import save_data_json
from kivymd.uix.menu import MDDropdownMenu
from kivy.properties import ObjectProperty


class ScreenAddData(MDScreen):
    previous_screen = ObjectProperty(None)

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
        self.tipo = self.ids['buton_text_dropdown'].text
        self.ejercicio = self.ids.adddata_textfield_ejercicio.text
        self.peso = self.ids.adddata_textfield_peso.text
        self.repeticiones = self.ids.adddata_textfield_repeticiones.text
        self.series = self.ids.adddata_textfield_series.text

        data = {
            "Tipo": self.tipo,
            "Ejercicio": self.ejercicio,
            "Peso": self.peso,
            "Repeticiones": self.repeticiones,
            "Series": self.series
            }
        print(self.tipo)
        if self.tipo not in ["Biceps", "Pectoral", "Espalda", "Triceps", "Hombros"]:
            print("not in category")
            return False
        save_data_json(new_data=data)
        self.parent.current = self.previous_screen

    def clear_textbox(self):

        self.ids.adddata_textfield_ejercicio.text = ""
        self.ids.adddata_textfield_peso.text = ""
        self.ids.adddata_textfield_repeticiones.text = ""
        self.ids.adddata_textfield_series.text = ""