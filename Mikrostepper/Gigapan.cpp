#include "stdafx.h"
#include "Gigapan.h"

#include <sstream>
#include <iostream>

using namespace std;

string gigapanRegistryRemove() {
	return "reg delete HKEY_CURRENT_USER\\Software\\GigaPan\\GigaPan /f";
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
