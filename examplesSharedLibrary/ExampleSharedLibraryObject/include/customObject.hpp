#pragma once

#include <lua.hpp>
#include <string>
#include <unordered_map>
#include <vector>


class CustomObject {
public:
    CustomObject(bool valueBool, double valueNumber, const std::string& valueString, const std::unordered_map<int, std::string>& valueTable);

    void setBoolean(bool valueBool);
    void setNumber(double valueNumber);
    void setString(const std::string& valueString);
    void setTable(const std::unordered_map<int, std::string>& valueTable);

    bool getBoolean() const;
    double getNumber() const;
    std::string getString() const;
    std::unordered_map<int, std::string> getTable() const;

    std::pair<double, double> getTuple() const;

    std::string debugString() const;

private:
    bool valueBool;
    double valueNumber;
    std::string valueString;
    std::unordered_map<int, std::string> valueTable;
};
