#ifndef GIGAPAN_H
#define GIGAPAN_H

#include <vector>
#include <string>

void runGigapan(const QString& savedir, const QStringList& files, int rows);
void runGigapanEx(const QString& savedir, const QStringList& files);
void runRegedit();
QSize deduceRowsCols(const QStringList& files);
QStringList rearrange(const QStringList& files);
bool checkRigid(const QStringList& files);

#endif // GIGAPAN_H