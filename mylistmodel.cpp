#include "mylistmodel.h"

MyListModel::MyListModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int MyListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_items.size();
}

QVariant MyListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return {};

    const Item &item = m_items.at(index.row());

    switch (role) {
    case TitleRole: return item.title;
    case ValueRole: return item.value;
    case DateTimeRole: return item.dateTime;
    case ContentRole: return item.content;
    }
    return {};
}

QHash<int, QByteArray> MyListModel::roleNames() const
{
    return {
        { TitleRole, "title" },
        { ValueRole, "value" },
        { DateTimeRole, "date" },
        { ContentRole, "content" }
    };
}

void MyListModel::addItem(const QString &title, double value, QDateTime dateTime, QString content)
{
    beginInsertRows(QModelIndex(), m_items.size(), m_items.size());
    m_items.append({ title, value, dateTime, content });
    endInsertRows();
}

void MyListModel::removeItem(int index)
{
    if (m_items.isEmpty())
        return;

    beginRemoveRows(QModelIndex(),index,index);
    m_items.removeAt(index);
    endRemoveRows();
}

void MyListModel::editItem(Item item, int index)
{
    if (m_items.isEmpty())
        return;

    m_items[index].EditItem(item);


    emit dataChanged(createIndex(index, 0), createIndex(index, 0), {TitleRole, ValueRole, DateTimeRole, ContentRole});
}

bool Item::EditItem(Item item)
{
    this->dateTime = item.dateTime;
    this->content = item.content;
    this->title = item.title;
    this->value = item.value;
    return true;
}
