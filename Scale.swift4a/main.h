// import header files or add definitions here that you want to be visible
// within Swift via the clang importer

// note that many AVR gcc constructs will not work, if you are having trouble
// getting something to compile, add a normal .c file (and optionally header)
// with wrapper functions, then declare the wrapper function here instead

#include <stdbool.h>

bool setupLoadCell();
uint8_t updateLoadCell();
void tareNoDelayLoadCell();
bool getTareStatusLoadCell();
bool refreshDataSetLoadCell();
float getNewCalibrationLoadCell(float known_mass);
float getDataLoadCell();
float getCalFactorLoadCell();
void setCalFactorLoadCell(float cal);
