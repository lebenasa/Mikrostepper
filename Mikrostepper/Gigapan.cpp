#include "stdafx.h"
#include "Gigapan.h"

#include <sstream>
#include <iostream>
#include <future>
#include <exception>
#include <QProcess>

using namespace std;

string gigapanRegistryRemove() {
	return "reg delete HKEY_CURRENT_USER\\Software\\GigaPan /f";
}

string gigapanCommand(const vector<string>& files, int rows) {
	stringstream out;
	out << " --nrows " << rows << " --images ";
	for (const auto& f : files) {
		out << f << " ";
	}
	out << "--translational --large-blend-region --force-vignette-correction --save-as ";
	out << "./gigapan/stitch.gigapan --stitch";
	return out.str();
}

void runRegedit()
{
	async([](){ QProcess::execute("reg delete HKEY_CURRENT_USER\\Software\\GigaPan\\GigaPan /f"); });
}

QString checkSpace(const QString& path)
{
	//if (path.contains(" "))
	//	return "\"" + path + "\"";
	return path;

	//auto lst = path.split(" ");
	//QString o;
	//for (auto s : lst)
	//	o.append(s + "\\ ");
	//return o;
}

void runGigapan(const QString& savedir, const QStringList& files, int rows)
{
	auto exe = QCoreApplication::applicationDirPath();
	auto gigapan = exe + "/Gigapan/stitch.exe";
	QStringList command;
	command << "--nrows" << QString::number(rows) << "--images";
	for (const auto& f : files)
		command << checkSpace(f);
	command << "--translational" << "--large-blend-region" << "--force-vignette-correction"
		<< "--save-as" << checkSpace(savedir + "/GigaPan/stitch.gigapan") << "--stitch";
	async([=](){ cout << "Called GigaPan\n"; QProcess::execute(gigapan, command); });
}

int extractNum(const QString& s)
{
	size_t i = 0;
	for (; i < s.size(); ++i)
	{
		if (s.at(i) == '0') continue;
		break;
	}
	return s.right(s.size() - i).toInt();
}

QSize deduceRowsCols(const QStringList& files)
{
	// Map file name to certain point
	vector<int> w, h;
	for (const auto& g : files)
	{
		QFileInfo gg{ g };
		auto f = gg.fileName();
		QString d = f.left(11);
		auto y = extractNum(d.left(5));
		auto x = extractNum(d.right(5));
		w.push_back(x);
		h.push_back(y);
	}
	int col = *max_element(begin(w), end(w)) - *min_element(begin(w), end(w)) + 1;
	int row = *max_element(begin(h), end(h)) - *min_element(begin(h), end(h)) + 1;
	return QSize{ col, row };
}

QStringList rearrange(const QStringList& files)
{
	QStringList o;
	auto cr = deduceRowsCols(files);
	int cols = cr.width();
	int rows = cr.height();

	// Map file name to certain point
	map<size_t, QString> m;
	vector<size_t> p;
	for (const auto& g : files)
	{
		QFileInfo gg{ g };
		auto f = gg.fileName();
		QString d = f.left(11);
		auto y = extractNum(d.left(5));
		auto x = extractNum(d.right(5));
		size_t id = cols * y + x;
		m[id] = g;
		p.push_back(id);
	}

	sort(begin(p), end(p));
	size_t min = p[0], max = p[p.size() - 1];
		
	for (size_t i = min; i < cols + min; ++i)
		for (size_t j = i; j < p.size() + min; j += cols)
			o << m.at(j);

	return o;
}

void runGigapanEx(const QString& savedir, const QStringList& files)
{
	if (!checkRigid(files)) return;
	runRegedit();
	auto fs = rearrange(files);
	auto cr = deduceRowsCols(files);
	runGigapan(savedir, fs, cr.height());
}

bool checkRigid(const QStringList& files)
{
	auto cr = deduceRowsCols(files);
	if (cr.width() * cr.height() != files.size())
		return false;
	return true;
}