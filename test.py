import sys
from PyQt6.QtWidgets import QApplication, QLabel, QVBoxLayout, QGroupBox, QWidget
from PyQt6.QtGui import QFont

class MyApp(QWidget):
    def __init__(self):
        super().__init__()
        self.init_ui()

    def init_ui(self):
        self.setWindowTitle('Group Box Example')
        self.setGeometry(100, 100, 300, 200)

        layout = QVBoxLayout()

        # Create a QGroupBox
        groupBox = QGroupBox("Право на вычет по льготам:")
        groupBox.setStyleSheet("color: yellow; font-size: 16px;")

        # Create a layout for the group box
        groupLayout = QVBoxLayout()
        groupBox.setLayout(groupLayout)

        # Add the group box to the main layout
        layout.addWidget(groupBox)
        self.setLayout(layout)

if __name__ == '__main__':
    app = QApplication(sys.argv)
    window = MyApp()
    window.show()
    sys.exit(app.exec())