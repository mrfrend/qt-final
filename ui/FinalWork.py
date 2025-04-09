# Import necessary modules from PyQt6
from PyQt6.QtWidgets import (
    QMainWindow,
    QLabel,
    QVBoxLayout,
    QHBoxLayout,
    QApplication,
    QWidget,
    QSpacerItem,
    QSizePolicy,
    QPushButton,
    QMessageBox,
)
from PyQt6.QtCore import Qt
from PyQt6.QtGui import QFont
from qt_material import apply_stylesheet

from dbhelper import Database
from ui.components import EmployeeComboBox, Priviliges, Operations, Calculations


class Deducations(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Калькулятор НДФЛ")
        self.setMinimumSize(650, 500)
        self.setMaximumSize(1000, 500)

        self.employeeComboBox = EmployeeComboBox()
        self.payment = QLabel("Зарплата: ")
        self.operations = Operations()
        self.benefits_group = Priviliges()
        self.calculations = Calculations()
        self.calculate_button = QPushButton("Рассчитать")
        self.write_button = QPushButton("Записать")

        # Initialize UI components
        self.init_ui()
        # Apply styles to the UI
        self.init_styles()

    def init_ui(self):
        # Create central widget and layout
        widget = QWidget()
        self.setCentralWidget(widget)
        v_layout = QVBoxLayout()
        v_layout.setContentsMargins(20, 20, 20, 20)
        widget.setLayout(v_layout)
        employee_info = Database.get_employee_info(1)
        self.payment.setText(f"Зарплата: {employee_info[2]}")
        self.payment.setAlignment(Qt.AlignmentFlag.AlignHCenter)
        self.payment.setFont(QFont("Arial", 24, QFont.Weight.Bold))

        # Create and configure heading
        self.heading = QLabel("<h1>Калькулятор расчета налоговой базы и НДФЛ</h1>")
        self.heading.setAlignment(Qt.AlignmentFlag.AlignHCenter)
        v_layout.addWidget(self.heading)
        v_layout.addSpacerItem(
            QSpacerItem(20, 20, QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Fixed)
        )
        # Create and configure employee selection
        v_layout.addWidget(self.employeeComboBox)
        v_layout.addWidget(self.payment)
        self.employeeComboBox.select_changed.connect(self.on_employee_changed)
        # Add employee selection to header layout

        # Add header layout to main layout

        benefit_calculation_layout = QHBoxLayout()
        benefit_calculation_layout.addWidget(self.benefits_group)
        benefit_calculation_layout.addWidget(self.calculations)
        v_layout.addLayout(benefit_calculation_layout)
        v_layout.addWidget(self.operations)

        buttons_layout = QHBoxLayout()

        buttons_layout.addWidget(self.calculate_button)
        buttons_layout.addWidget(self.write_button)

        self.calculate_button.clicked.connect(self.on_calculate_clicked)
        self.write_button.clicked.connect(self.on_write_clicked)

        v_layout.addLayout(buttons_layout)
        v_layout.addStretch(1)

    def on_employee_changed(self, employee_id: str):
        self.benefits_group.update_content(int(employee_id))
        employee_info = Database.get_employee_info(int(employee_id))
        self.payment.setText(f"Зарплата: {employee_info[2]}")

    def init_styles(self):
        # Apply styles to the main window and labels
        self.setStyleSheet(
            """
            Deducations {
                background-color: purple;
            }
            QLabel {
                color: yellow;
                
            }

            #employee_label {
                font-size: 24px;
                font-weight: bold;
            }
            """
        )

    def on_calculate_clicked(self):
        choosed_operation: int = self.operations.selected_operation_id
        choosed_employee: int = self.employeeComboBox.selected_employee_id
        choosed_priviliges: list[bool] = self.benefits_group.selected_priviliges

        calculation: float | None = Database.call_calculate_procedure(
            choosed_employee, choosed_operation, choosed_priviliges
        )
        if calculation is not None:
            self.calculations.set_calculation(calculation)
        else:
            self.calculations.set_calculation(0)

    def on_write_clicked(self):
        choosed_operation: int = self.operations.selected_operation_id
        choosed_employee: int = self.employeeComboBox.selected_employee_id
        choosed_priviliges: list[bool] = self.benefits_group.selected_priviliges
        try:
            Database.call_write_procedure(
                choosed_employee, choosed_operation, choosed_priviliges
            )
            msg = QMessageBox()
            msg.setIcon(QMessageBox.Icon.Information)
            msg.setText("Данные успешно записаны")
            msg.setWindowTitle("Успех")
            msg.exec()
        except Exception as e:
            print(e)


if __name__ == "__main__":
    # Create application and main window
    app = QApplication([])
    window = Deducations()
    window.show()

    # Apply external stylesheet
    apply_stylesheet(app, theme="dark_blue.xml")
    app.exec()
