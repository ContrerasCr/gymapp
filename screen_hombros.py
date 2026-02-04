from kivymd.uix.screen import MDScreen
from kivy.properties import ObjectProperty
from functions import add_item_list


class ScreenHombros(MDScreen):
    list_container = ObjectProperty(None)
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.tipo_ejercicio = "Hombros"

    def on_enter(self):
        """Cargar los datos de ejemplo en la lista"""
        lista_widget = self.ids.lista_hombros
        add_item_list(self, lista_widget, self.tipo_ejercicio)

    def add_info(self):
        self.parent.current = "add-data"

    def edit_data(self, data):
        screen = self.manager.get_screen("edit-data")
        screen.data = data
        screen.previous_screen = "hombros"
        self.parent.current = "edit-data"