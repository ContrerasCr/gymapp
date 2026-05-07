# main.py
from kivymd.app import MDApp
from kivy.lang import Builder
from kivymd.uix.screen import MDScreen
from kivymd.uix.list import MDListItem, MDListItemHeadlineText, MDListItemSupportingText, MDListItemLeadingIcon, MDListItemTrailingIcon
from navigation import MyNavigationDrawer
from kivy.properties import ObjectProperty
from kivy.clock import Clock
from kivymd.uix.textfield import MDTextField
from kivymd.uix.button import MDButton
from kivymd.uix.menu import MDDropdownMenu

from screen_add_data import ScreenAddData
from screen_edit import ScreenEditData
from screen_pectoral import ScreenPectoral
from screen_biceps import ScreenBiceps
from screen_triceps import ScreenTriceps
from screen_espalda import ScreenEspalda
from screen_hombros import ScreenHombros

from functions import add_item_list
# Definimos nuestros datos de ejemplo


class ScreenEnter(MDScreen):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        Clock.schedule_once(lambda dt: self.on_pre_enter())

    def on_enter(self):
        Clock.schedule_once(lambda dt: self.cambiar_pantalla(), 0.1)

    def cambiar_pantalla(self):
        self.parent.current = "pectoral"
        

class ListaApp(MDApp):
    def build(self):
        self.theme_cls.theme_style = "Dark"
        self.theme_cls.primary_palette = "Blue"
        self.theme_cls.text_color = "White"

        return Builder.load_file("design.kv")
    

if __name__ == '__main__':
    ListaApp().run()