#pragma once

#ifdef _WIN32
#include <string>
#include <filesystem>
#include <locale>
#include <codecvt>

inline std::string pathToUtf8(const std::filesystem::path& path) {
    std::wstring_convert<std::codecvt_utf8<wchar_t>> converter;
    return converter.to_bytes(path.wstring());
}
#endif
