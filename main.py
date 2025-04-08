from PyQt6.QtWidgets import QApplication

from ui.FinalWork import Deducations
from qt_material import apply_stylesheet

if __name__ == "__main__":
    app = QApplication([])
    window = Deducations()
    window.show()
    apply_stylesheet(app, theme="dark_teal.xml")
    app.exec()
