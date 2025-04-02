from PyQt6.QtWidgets import (
    QMainWindow,
    QComboBox,
    QRadioButton,
    QButtonGroup,
    QPushButton,
    QCheckBox,
    QLabel,
    QVBoxLayout,
    QHBoxLayout,
    QApplication,
    QWidget,
)
from PyQt6.QtCore import Qt
from PyQt6.QtGui import QFont
from qt_material import apply_stylesheet


class Deducations(QMainWindow):

    def __init__(self):
        super().__init__()
        self.setWindowTitle("Калькулятор НДФЛ")
        self.heading = QLabel("<h1>Калькулятор расчета налоговой базы и НДФЛ</h1>")
        self.header = QHBoxLayout()
        self.employeeComboBox = QComboBox()
        self.setMinimumSize(600, 500)
        self.init_ui()
        self.init_styles()

    def init_ui(self):
        widget = QWidget()
        self.setCentralWidget(widget)
        v_layout = QVBoxLayout()
        widget.setLayout(v_layout)

        self.heading.setAlignment(Qt.AlignmentFlag.AlignHCenter)
        self.employeeComboBox = QComboBox()
        self.employeeComboBox.setFixedWidth(200)
        v_layout.addWidget(self.heading)
        employee_label = QLabel("Сотрудник:")
        employee_label.setFont(QFont("Arial", 24))
        self.header.addWidget(employee_label)
        self.header.addWidget(self.employeeComboBox)
        self.header.setAlignment(Qt.AlignmentFlag.AlignHCenter)
        self.header.setSpacing(20)

        v_layout.addLayout(self.header)
        v_layout.addStretch(1)

    def init_styles(self):
        self.setStyleSheet(
            "Deducations {"
            "background-color: purple;"
            "}"
            "QLabel {"
            "color: yellow;"
            "}"
        )


if __name__ == "__main__":
    app = QApplication([])
    window = Deducations()
    window.show()
    apply_stylesheet(app, theme="dark_blue.xml")
    app.exec()
