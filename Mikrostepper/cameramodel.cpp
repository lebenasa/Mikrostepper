#include "stdafx.h"
#include "cameramodel.h"
#include <future>
#include <QtConcurrent>

#include "Gigapan.h"

using namespace std;

CameraModel::CameraModel(const QSize &size, QObject *parent)
	: QAbstractListModel(parent), m_row(0), m_col(0)
{
    initModel(size.height(), size.width());
}

CameraModel::~CameraModel()
{
    clearBuffers();
}

int CameraModel::rowCount(const QModelIndex& parent) const {
    Q_UNUSED(parent)
    return m_row * m_col;
}

QVariant CameraModel::data(const QModelIndex& index, int role) const {
    if (index.row() < 0 || index.row() >= m_row * m_col)
        return QVariant();
    if (role == BufferRole)
        return m_buffer.at(index.row());
    else if (role == SelectedRole)
        return m_selected.at(index.row());
    else if (role == HighlightRole)
        return m_highlight.at(index.row());

    return QVariant();
}

bool CameraModel::setData(const QModelIndex & index, const QVariant & value, int role) {
    if (role == SelectedRole) {
        m_selected[index.row()] = value.toBool();
        emit dataChanged(index, index, { SelectedRole });
        return true;
    }
    if (role == HighlightRole) {
        m_highlight[index.row()] = value.toBool();
        emit dataChanged(index, index, { HighlightRole });
        return true;
    }
    return false;
}

Qt::ItemFlags CameraModel::flags(const QModelIndex& index) const {
    Q_UNUSED(index)
    return Qt::ItemIsEditable;
}

QHash<int, QByteArray> CameraModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[BufferRole] = "buffer";
    roles[SelectedRole] = "selected";
    roles[HighlightRole] = "highlight";
    return roles;
}

int CameraModel::rows() const {
    return m_row;
}

int CameraModel::cols() const {
    return m_col;
}

QPoint CameraModel::selectedCell() const {
    auto p = find(begin(m_selected), end(m_selected), true);
    return indexToPoint(p - begin(m_selected));
}

vector<QPoint> CameraModel::selectedCells() const {
    vector<QPoint> res;
    for(size_t i = 0; i < m_selected.size(); ++i) {
        if (m_selected.at(i))
            res.push_back(indexToPoint(i));
    }
    return res;
}

void CameraModel::initModel(int row, int col) {
    clearBuffers();
    auto index = this->createIndex(0, 0);
    beginRemoveRows(index, 0, rowCount());
    m_buffer.erase(begin(m_buffer), end(m_buffer));
    m_selected.erase(begin(m_selected), end(m_selected));
    m_hasImage.erase(begin(m_hasImage), end(m_hasImage));
    endRemoveRows();

    beginInsertRows(index, 0, row * col);
    
    m_selected = vector<bool>(row * col);
    fill(begin(m_selected), end(m_selected), false);
    
    m_hasImage = vector<bool>(row * col);
    fill(begin(m_hasImage), end(m_hasImage), false);
    
    m_highlight = vector<bool>(row * col);
    fill(begin(m_highlight), end(m_highlight), false);
    
    m_buffer = vector<QImage>(row * col);
    auto genImg = []() -> QImage {
            auto im = QImage(10, 10, QImage::Format_RGB888);
            im.fill("#2c3e50");
            return im;
};
    auto first = begin(m_buffer);
    while (first != end(m_buffer)) {
        *first = genImg();
        ++first;
    }
    
    endInsertRows();

    m_row = row;
    emit rowsChanged(m_row);
    m_col = col;
    emit colsChanged(m_col);
}

void CameraModel::clearBuffers() {
    for(size_t i = 0; i < m_hasImage.size(); ++i) {
        if (m_hasImage.at(i))
            clearBuffersAt(indexToPoint(i));
    }
}

void CameraModel::clearSelectedBuffers() {
    for (const auto& selected : selectedCells()) {
        clearBuffersAt(selected);
    }
}

void CameraModel::clearBuffersAt(const QPoint& target) {
    auto index = pointToIndex(target);
    QImage im(10, 10, QImage::Format_RGB888);
    im.fill("#2c3e50");
    m_buffer[index] = im;
    m_hasImage[index] = false;
    auto mi = createIndex(index, 0);
    emit dataChanged(mi, mi, { BufferRole });
}

void CameraModel::updateBuffer(const QImage& buffer, const QPoint& target) {
    int index = target.x() + target.y() * m_row;
    if (index >= 0 && index < rowCount()) {
        m_buffer[index] = buffer.copy();
        m_hasImage[index] = true;
        auto modelIndex = createIndex(index, 0);
        emit dataChanged(modelIndex, modelIndex, { BufferRole });
    }
}

using SaveImage = std::pair<QImage, QString>;
void saveimages(const std::vector<SaveImage>& jobs) {
    for (auto job : jobs) {
        job.first.save(job.second);
    }
}

void CameraModel::saveBuffersPrivate(const QUrl& baseDir, std::function<bool(size_t)> comp)
{
	std::vector<SaveImage> workit;
	m_files.clear();
	m_saveDir = baseDir.toLocalFile();

    for (size_t i = 0; i < m_hasImage.size(); ++i) {
        if (m_hasImage.at(i) && comp(i)) {
            auto pt = indexToPoint(i);
            auto base = baseDir.toLocalFile();
            auto fn = base + "/" + QString("%1_%2.png").arg(pt.y()+1, 5, 10, QChar('0')).
				arg(pt.x()+1, 5, 10, QChar('0'));
            SaveImage saveit;
            saveit.first = m_buffer[i].copy();
            saveit.second = fn;
            workit.push_back(saveit);

			m_files.push_back(fn);
        }
	}

	auto saveFn = [=]() { saveimages(workit); emit saveCompleted(); };
	async(launch::async, saveFn);
}

void CameraModel::saveBuffers(const QUrl &baseDir) {
	saveBuffersPrivate(baseDir, [](size_t){ return true; });
}

void CameraModel::saveSelectedBuffers(const QUrl &baseDir) {
	saveBuffersPrivate(baseDir, [this](size_t i){ return m_selected.at(i); });
}

void CameraModel::clearSelection() {
    fill(begin(m_selected), end(m_selected), false);
    auto tl = createIndex(0, 0);
    auto br = createIndex(rowCount() - 1, 0);
    emit dataChanged(tl, br, { SelectedRole });
}

void CameraModel::select(const QPoint& target) {
    auto index = pointToIndex(target);
    m_selected[index] = true;
    auto mi = createIndex(index, 0);
    emit dataChanged(mi, mi, { SelectedRole });
}

void CameraModel::multiselect(const QPoint &tl, const QPoint &br) {
    for (int y = tl.y(); y <= br.y(); ++y) {
        for (int x = tl.x(); x <= br.x(); ++x) {
            select(QPoint(x, y));
        }
    }
}

void CameraModel::invertSelection() {
    for (size_t i = 0; i < m_selected.size(); ++i) {
        m_selected[i] = !m_selected.at(i);
        auto mi = createIndex(i, 0);
        emit dataChanged(mi, mi, { SelectedRole });
    }
}

void CameraModel::highlight(const QPoint &target) {
    auto index = pointToIndex(target);
    m_highlight[index] = true;
    auto mi = createIndex(index, 0);
    emit dataChanged(mi, mi, { HighlightRole });
}

void CameraModel::unhighlight() {
    fill(begin(m_highlight), end(m_highlight), false);
    auto tl = createIndex(0, 0);
    auto br = createIndex(rowCount() - 1, 0);
    emit dataChanged(tl, br, { HighlightRole });
}

QPoint CameraModel::indexToPoint(int index) const {
    int col = index % m_row;
    int row = (index - col) / m_col;
    return QPoint(col, row);
}

int CameraModel::pointToIndex(const QPoint& point) const {
    return point.x() + point.y() * m_col;
}

std::vector<QPoint> CameraModel::autoFill() const {
    if (count(begin(m_hasImage), end(m_hasImage), true) < 2)
        return vector<QPoint>();
    // Find top-left and bottom-right filled cell
    auto first_i = find(begin(m_hasImage), end(m_hasImage), true);
    int first = distance(begin(m_hasImage), first_i);
    auto last_i = find(rbegin(m_hasImage), rend(m_hasImage), true);
    int last = distance(begin(m_hasImage), last_i.base());
    int tly = indexToPoint(first).y();
    int bry = indexToPoint(last).y();
    int tlx = -1;
    for (int x = 0; x < m_col; ++x) {
        for (int y = 0; y < m_row; ++y) {
            if (m_hasImage.at(pointToIndex(QPoint(x, y)))) {
                tlx = x;
                break;
            }
        }
        if (tlx != -1)
            break;
    }
    int brx = -1;
    for (int x = m_col-1; x >= 0; --x) {
        for (int y = 0; y < m_row; ++y) {
            if (m_hasImage.at(pointToIndex(QPoint(x, y)))) {
                brx = x;
                break;
            }
        }
        if (brx != -1)
            break;
    }
    
    QPoint tl { tlx, tly };
    QPoint br { brx, bry };
    
    std::vector<QPoint> res, temp;
    for (int y = tl.y(); y <= br.y(); ++y) {
        for (int x = tl.x(); x <= br.x(); ++x) {
            temp.push_back(QPoint(x, y));
        }
    }
    int x = 0;
    auto pred = [&](int a, int b) {
        return (find(begin(temp), end(temp), QPoint(a, b)) != end(temp)) &
                !m_hasImage.at(pointToIndex(QPoint(a, b)));
    };
    for (int y = 0; y < m_row; ++y) {
        for (int i = 0; i < m_col; ++i) {
            if (pred(x, y))
                res.push_back(QPoint(x, y));
            x = (y%2 == 0) ? x + 1 : x - 1;
        }
        x = (y%2 == 0) ? x - 1 : x + 1;
    }
    return res;
}

std::vector<QPoint> CameraModel::boxFill() const {
    // Selection is already restricted to box area by UI,
    // thus we simply return selected cells with empty image
    std::vector<QPoint> res;
    int x = 0;
    auto pred = [this](int a, int b) {
        return m_selected.at(pointToIndex(QPoint(a,b))) &
                !m_hasImage.at(pointToIndex(QPoint(a,b)));
    };
    for (int y = 0; y < m_row; ++y) {
        for (int i = 0; i < m_col; ++i) {
            if (pred(x, y))
                res.push_back(QPoint(x, y));
            x = (y%2 == 0) ? x + 1 : x - 1;
        }
        x = (y%2 == 0) ? x - 1 : x + 1;
    }
    return res;
}

int CameraModel::selectedCount() {
    return count(begin(m_selected), end(m_selected), true);
}

void CameraModel::shiftData(const QSize &shift) {
    int h = shift.width();
    int v = shift.height();
    if (abs(h) > cols() && abs(v) > rows()) {
        clearBuffers();
        return;
    }
    if (h == 0 && v == 0)
        return;
    bool shiftSelected = (selectedCount() == 1);
    auto genImg = []() -> QImage {
            auto im = QImage(10, 10, QImage::Format_RGB888);
            im.fill("#2c3e50");
            return im; };
    if (v > 0) {
        // Shift up
        for (int i = 0; i < v; ++i) {
            auto f1 = begin(m_hasImage);
            fill(f1, f1 + cols(), false);
            rotate(f1, f1 + cols(), f1 + (rows() * cols()));

            auto f2 = begin(m_buffer);
            auto im = genImg();
            fill(f2, f2 + cols(), im);
            rotate(f2, f2 + cols(), f2 + (rows() * cols()));
            if (shiftSelected) selectUp();
        }
    }
    else if (v < 0) {
        // Shift down
        for (int i = 0; i < abs(v); ++i) {
            auto f1 = begin(m_hasImage);\
            fill(f1 + ((rows()-1) * cols()), f1 + (rows() * cols()), false);
            rotate(f1, f1 + ((rows()-1) * cols()), f1 + (rows() * cols()));

            auto f2 = begin(m_buffer);\
            auto im = genImg();
            fill(f2 + ((rows()-1) * cols()), f2 + (rows() * cols()), im);
            rotate(f2, f2 + ((rows()-1) * cols()), f2 + (rows() * cols()));
            if (shiftSelected) selectDown();
        }
    }

    if (h > 0) {
        // Shift Left
        for (int i = 0; i < h; ++i) {
            for (int j = 0; j < rows(); ++j) {
                auto f1 = begin(m_hasImage) + (j*rows());
                m_hasImage[j*rows()] = false;
                rotate(f1, f1 + 1, f1 + cols());

                auto f2 = begin(m_buffer) + j*rows();
                m_buffer[j*rows()] = genImg();
                rotate(f2, f2 + 1, f2 + cols());
            }
            if (shiftSelected) selectLeft();
        }
    }
    else if (h < 0) {
        // Shift Right
        for (int i = 0; i < abs(h); ++i) {
            for (int j = 0; j < rows(); ++j) {
                auto f1 = begin(m_hasImage) + (j*rows());
                rotate(f1, f1 + (cols()-1), f1 + cols());
                m_hasImage[j*rows()] = false;

                auto f2 = begin(m_buffer) + (j*rows());
                rotate(f2, f2 + (cols()-1), f2 + cols());
                m_buffer[j*rows()] = genImg();
            }
            if (shiftSelected) selectRight();
        }
    }

    if (!shiftSelected) clearSelection();
    emit dataChanged(index(0), index(rowCount()-1), { BufferRole });
}

void CameraModel::selectUp() {
    if (selectedCount() != 1) return;
    auto selected = selectedCell();
    if (selected.y() == 0) return;
    clearSelection();
    select(QPoint(selected.x(), selected.y()-1));
}

void CameraModel::selectRight() {
    if (selectedCount() != 1) return;
    auto selected = selectedCell();
    if (selected.x() == cols()-1) return;
    clearSelection();
    select(QPoint(selected.x()+1, selected.y()));
}

void CameraModel::selectDown() {
    if (selectedCount() != 1) return;
    auto selected = selectedCell();
    if (selected.y() == rows()-1) return;
    clearSelection();
    select(QPoint(selected.x(), selected.y()+1));
}

void CameraModel::selectLeft() {
    if (selectedCount() != 1) return;
    auto selected = selectedCell();
    if (selected.x() == 0) return;
    clearSelection();
    select(QPoint(selected.x()-1, selected.y()));
}

void CameraModel::toggleGigapan(bool t) {
	if (t) connect(this, &CameraModel::saveCompleted, this, &CameraModel::runGigapan);
	else disconnect(this, &CameraModel::saveCompleted, this, &CameraModel::runGigapan);
}

void CameraModel::runGigapan() {
	runGigapanEx(m_saveDir, m_files);
}