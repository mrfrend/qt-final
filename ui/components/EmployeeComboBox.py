from PyQt6.QtWidgets import QWidget, QHBoxLayout, QComboBox, QLabel
from PyQt6.QtGui import QFont
from PyQt6.QtCore import pyqtSignal, Qt
from dbhelper import Database


class EmployeeComboBox(QWidget):

    select_changed = pyqtSignal(str)

    def __init__(self):
        super().__init__()
        self.combo_box = QComboBox()

        self.init_ui()

    def init_ui(self):
        h_layout = QHBoxLayout()

        employee_label = QLabel("Сотрудник:")
        employee_label.setFont(QFont("Arial", 24, QFont.Weight.Bold))

        employees = Database.get_employees()
        for employee in employees:
            self.combo_box.addItem(employee[1])

        h_layout.addWidget(employee_label)
        h_layout.addWidget(self.combo_box)
        h_layout.setAlignment(Qt.AlignmentFlag.AlignHCenter)
        h_layout.setSpacing(20)

        self.combo_box.currentIndexChanged.connect(self.on_employee_changed)

        self.setStyleSheet(
            """
            QComboBox {
                color: white;               
            }

        """
        )
        self.setLayout(h_layout)

    @property
    def selected_employee_id(self) -> int:
        return self.combo_box.currentIndex() + 1

    def on_employee_changed(self, index):
        self.select_changed.emit(str(index + 1))
