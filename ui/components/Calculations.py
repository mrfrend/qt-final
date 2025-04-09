from PyQt6.QtWidgets import QGroupBox, QVBoxLayout, QLabel


class Calculations(QGroupBox):
    def __init__(self):
        super().__init__("Расчеты")
        self.layout = QVBoxLayout()
        self.calculation_label = QLabel("")
        self.init_ui()

    def init_ui(self):
        self.setLayout(self.layout)
        self.layout.addWidget(self.calculation_label)

    def set_calculation(self, calculation: float):
        self.calculation_label.setText(f"Сумма: {calculation}")
