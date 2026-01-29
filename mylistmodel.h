#ifndef MYLISTMODEL_H
#define MYLISTMODEL_H

#include <QAbstractListModel>
#include <QDateTime>
#include <QObject>

// ساختار یک آیتم
class Item {
public:
    QString title;
    double value;
    QDateTime dateTime;
    QString content;

    bool EditItem(Item item);
};

class MyListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    explicit MyListModel(QObject *parent = nullptr);

    // کلیدهای Role
    enum Roles {
        TitleRole = Qt::UserRole + 1,
        ValueRole                   ,
        DateTimeRole                     ,
        ContentRole
    };

    // توابع پایهٔ QAbstractListModel:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    // توابع کنترل داده‌ها
    void addItem(const QString &title, double value, QDateTime dateTime, QString content);
    void removeItem(int index);
    void editItem(Item item,int index);

private:
    QList<Item> m_items;
};

#endif // MYLISTMODEL_H
