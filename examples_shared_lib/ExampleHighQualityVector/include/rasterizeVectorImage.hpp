#pragma once

#include <filesystem>


std::filesystem::path rasterizeVectorImage(const std::filesystem::path& svg_file, double target_width);
