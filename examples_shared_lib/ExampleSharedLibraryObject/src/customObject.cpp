#include <customObject.hpp>
#include <sstream>

// Constructor Implementation
CustomObject::CustomObject(bool valueBool, double valueNumber, const std::string& valueString, const std::unordered_map<int, std::string>& valueTable)
    : valueBool(valueBool), valueNumber(valueNumber), valueString(valueString), valueTable(valueTable) {}

// Setter Implementations
void CustomObject::setBoolean(bool valueBool) {
    this->valueBool = valueBool;
}

void CustomObject::setNumber(double valueNumber) {
    this->valueNumber = valueNumber;
}

void CustomObject::setString(const std::string& valueString) {
    this->valueString = valueString;
}

void CustomObject::setTable(const std::unordered_map<int, std::string>& valueTable) {
    this->valueTable = valueTable;
}

// Getter Implementations
bool CustomObject::getBoolean() const {
    return valueBool;
}

double CustomObject::getNumber() const {
    return valueNumber;
}

std::string CustomObject::getString() const {
    return valueString;
}

std::unordered_map<int, std::string> CustomObject::getTable() const {
    return valueTable;
}

// Return a pair containing values, e.g., for a tuple.
std::pair<double, double> CustomObject::getTuple() const {
    return {valueNumber, static_cast<double>(valueBool)};
}

std::string CustomObject::debugString() const {
    std::ostringstream logMessage;
    logMessage << "{ bool=" << (valueBool ? "true" : "false")
            << ", number=" << valueNumber
            << ", string=\"" << valueString << "\""
            << ", table={";

    bool first = true;
    for (const auto& [key, val] : valueTable) {
        if (!first) logMessage << ", ";
        logMessage << key << "=\"" << val << "\"";
        first = false;
    }

    logMessage << "} }";

    return logMessage.str();
}
