#include <QApplication>
#include <QMessageBox>
#include <QString>
#include <iostream>

void show_popup(const QString &dependants) {
    QMessageBox msg;
    msg.setWindowTitle("WARNING!!");
    msg.setText("The following packages are depends_on_removed :\n" + dependants + "\nDo you want to remove them?");
    msg.setIcon(QMessageBox::Question);
    msg.setStandardButtons(QMessageBox::Cancel | QMessageBox::Yes | QMessageBox::No );
    msg.setDefaultButton(QMessageBox::Cancel);

    int result = msg.exec();

    if (result == QMessageBox::Yes) {
        std::cout << "ok" << std::endl;
    } else if (result == QMessageBox::No) {
        std::cout << "not ok" << std::endl;
    } else{
        std::cout << "do not remove" << std::endl;
    }
}

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);

    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " <dependants>" << std::endl;
        return 1;
    }

    QString dependants = argv[1];
    show_popup(dependants);

    return 0;
}
