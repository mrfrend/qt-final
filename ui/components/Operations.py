from PyQt6.QtWidgets import QGroupBox, QHBoxLayout, QRadioButton, QButtonGroup
from state import REALISED_OPERATIONS
from dbhelper import Database


class Operations(QGroupBox):
    def __init__(self):
        super().__init__("Тип операции")
        self.layout: QHBoxLayout = QHBoxLayout()
        self.buttons = QButtonGroup()
        self.init_ui()

    @property
    def selected_operation_id(self):
        return self.buttons.checkedId()

    def init_ui(self):
        operations = Database.get_type_operations()
        for idx, operation in enumerate(operations):
            radio_button = QRadioButton(operation)
            if idx == 0:
                radio_button.setChecked(True)
            if idx + 1 > REALISED_OPERATIONS:
                radio_button.setDisabled(True)
            self.layout.addWidget(radio_button)
            self.buttons.addButton(radio_button, idx + 1)
        self.setLayout(self.layout)
