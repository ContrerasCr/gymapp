from kivymd.app import MDApp
from kivy.lang import Builder
from kivy.properties import StringProperty
from kivy.clock import Clock
from kivymd.uix.navigationbar import MDNavigationBar, MDNavigationItem
from kivymd.uix.navigationdrawer import MDNavigationDrawer
from kivymd.uix.screen import MDScreen
from kivymd.uix.list import MDListItem, MDListItemHeadlineText, MDListItemSupportingText



class MyNavigationDrawer(MDNavigationDrawer):

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        Clock.schedule_once(lambda dt: self.on_pre_enter())

    def on_pre_enter(self):
        """Se ejecuta antes de que el drawer sea visible"""
        Clock.schedule_once(self._load_dynamic_items)

    def _load_dynamic_items(self, dt):
        """Carga los items dinámicos con seguridad"""
        try:
            # 1. Limpiar contenedor (usando ID correcto)
            container = self.ids.drawer_container
            container.clear_widgets()

            # 2. Obtener datos (ejemplo con SQLite)
            data = self._get_navigation_data()  # Método separado para mejor organización

            # 3. Crear items dinámicos
            for record in data:
                self._add_navigation_item(record)
        except Exception as e:
            print(f"Error cargando items: {e}")

    def _get_navigation_data(self):
        """Obtiene datos para el menú (puedes conectar a BD real aquí)"""
        return [
            {'id': 1, 'nombre': 'Pectoral', 'screen': 'pectoral'},
            {'id': 2, 'nombre': 'Biceps', 'screen': 'biceps'},
            {'id': 3, 'nombre': 'Espalda', 'screen': 'espalda'},
            {'id': 4, 'nombre': 'Triceps', 'screen': 'triceps'},
            {'id': 5, 'nombre': 'Hombros', 'screen': 'hombros'},
            
        ]

    def _add_navigation_item(self, record):
        """Crea y añade un item de menú"""
        item = MDListItem(
            MDListItemHeadlineText(text=record['nombre']),
            on_release=lambda x, r=record: self.item_selected(r)
        )
        self.ids.drawer_container.add_widget(item)

    def item_selected(self, record):
        """Maneja la selección de un item"""
        try:
            # 1. Cerrar el drawer
            self.set_state("close")
            
            # 2. Cambiar de pantalla
            self.parent.ids.screen_manager.current = record['screen']

        except Exception as e:
            print(f"Error navegando: {e}")