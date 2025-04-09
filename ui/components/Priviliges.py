from PyQt6.QtWidgets import QGroupBox, QVBoxLayout, QCheckBox, QButtonGroup
from dbhelper import Database


class Priviliges(QGroupBox):
    def __init__(self):
        super().__init__("Право на вычет по льготам")
        self.layout = QVBoxLayout()
        self.checkboxes: QButtonGroup = QButtonGroup()
        self.init_ui()

    def init_ui(self):
        self.checkboxes.setExclusive(False)
        self.setLayout(self.layout)
        self.update_content(1)

    @property
    def selected_priviliges(self):
        return [checkbox.isChecked() for checkbox in self.checkboxes.buttons()]

    def update_content(self, employee_id: int):
        self.clear_layout()
        priviliges: dict[str, bool] = Database.get_priviliges_by_employee_id(
            employee_id
        )
        for idx, (priviligy, is_accesible) in enumerate(priviliges.items()):
            checkbox = QCheckBox(priviligy)
            checkbox.setEnabled(is_accesible)
            self.checkboxes.addButton(checkbox, idx + 1)
            self.layout.addWidget(checkbox)

    def clear_layout(self):
        for i in reversed(range(self.layout.count())):
            widget = self.layout.itemAt(i).widget()
            if widget is not None:
                widget.setParent(None)
                widget.deleteLater()
