#ifndef GIGAPAN_H
#define GIGAPAN_H

#include <vector>
#include <string>

std::string gigapanRegistryRemove();
std::string gigapanCommand(const std::vector<std::string>& files, int rows);

#endif // GIGAPAN_H