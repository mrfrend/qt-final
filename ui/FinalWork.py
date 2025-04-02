# Import necessary modules from PyQt6
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
    QSpacerItem,
    QSizePolicy,
)
from PyQt6.QtCore import Qt
from PyQt6.QtGui import QFont
from qt_material import apply_stylesheet


class Deducations(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Калькулятор НДФЛ")
        self.setFixedSize(600, 500)

        # Initialize UI components
        self.init_ui()
        # Apply styles to the UI
        self.init_styles()

    def init_ui(self):
        # Create central widget and layout
        widget = QWidget()
        self.setCentralWidget(widget)
        v_layout = QVBoxLayout()
        v_layout.setContentsMargins(0, 20, 0, 0)
        widget.setLayout(v_layout)

        # Create and configure heading
        self.heading = QLabel("<h1>Калькулятор расчета налоговой базы и НДФЛ</h1>")
        self.heading.setAlignment(Qt.AlignmentFlag.AlignHCenter)
        v_layout.addWidget(self.heading)
        v_layout.addSpacerItem(
            QSpacerItem(20, 20, QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Fixed)
        )
        # Create and configure employee selection
        self.employeeComboBox = QComboBox()
        self.employeeComboBox.setMinimumWidth(250)
        self.employeeComboBox.setSizePolicy(
            QSizePolicy.Policy.Preferred, QSizePolicy.Policy.Fixed
        )
        employee_label = QLabel("Сотрудник:")
        employee_label.setObjectName("employee_label")
        employee_label.setFont(QFont("Arial", 24, QFont.Weight.Bold))

        # Add employee selection to header layout
        self.header = QHBoxLayout()
        self.header.addWidget(employee_label)
        self.header.addWidget(self.employeeComboBox)
        self.header.setAlignment(Qt.AlignmentFlag.AlignHCenter)
        self.header.setSpacing(20)

        # Add header layout to main layout
        v_layout.addLayout(self.header)
        v_layout.addStretch(1)

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


if __name__ == "__main__":
    # Create application and main window
    app = QApplication([])
    window = Deducations()
    window.show()

    # Apply external stylesheet
    apply_stylesheet(app, theme="dark_blue.xml")
    app.exec()
