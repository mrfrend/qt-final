from PyQt6.QtWidgets import QGroupBox, QHBoxLayout, QRadioButton, QButtonGroup
from dbhelper import Database


class Operations(QGroupBox):
    def __init__(self):
        super().__init__("Тип операции")
        self.layout: QHBoxLayout = QHBoxLayout()
        self.selected_radio_button = None
        self.buttons = QButtonGroup()
        self.init_ui()

    @property
    def selected_operation_id(self):
        return self.buttons.checkedId()

    def init_ui(self):
        operations = Database.get_type_operations()
        for idx, operation in enumerate(operations):
            radio_button = QRadioButton(operation)
            self.layout.addWidget(radio_button)
            self.buttons.addButton(radio_button, idx + 1)
        self.setLayout(self.layout)
