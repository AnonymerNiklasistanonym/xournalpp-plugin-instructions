#include <rasterizeVectorImage.hpp>

#include <stdexcept>
#include <format>

#include <librsvg/rsvg.h>
#include <cairo.h>

#include <iostream>

#ifdef _WIN32
#include <fixWin32Filesystem.hpp>
#endif


std::pair<double, double> getSvgDimensions(RsvgHandle* handle) {
    gdouble width, height;
    rsvg_handle_get_intrinsic_size_in_pixels(handle, &width, &height);
    if (width > 0 && height > 0) {
        return {static_cast<double>(width), static_cast<double>(height)};
    }

    gboolean has_width, has_height, has_rectangle;
    RsvgLength intrinsicWidth, intrinsicHeight;
    RsvgRectangle intrinsicRectangle;
    rsvg_handle_get_intrinsic_dimensions(handle, &has_width, &intrinsicWidth, &has_height, &intrinsicHeight, &has_rectangle, &intrinsicRectangle);
    if (has_width && has_height && has_rectangle && intrinsicWidth.length > 0 && intrinsicHeight.length > 0) {
        return {static_cast<double>(intrinsicRectangle.width), static_cast<double>(intrinsicRectangle.height)};
    }

    throw std::runtime_error("[RSVG] Error: SVG does not define valid dimensions!");
}


std::filesystem::path rasterizeVectorImage(const std::filesystem::path& svg_file, double target_width) {

    // Initialize
    RsvgHandle* handle = rsvg_handle_new_from_file(
        #ifdef _WIN32
        pathToUtf8(svg_file).c_str(),
        #else
        svg_file.c_str(),
        #endif
        NULL
    );
    if (!handle) {
        throw std::runtime_error(std::format("[RSVG] Error: Loading SVG file '{}'!", svg_file.string()));
    }

    // Get SVG intrinsic size in pixels (using the newer API)
    auto [width, height] = getSvgDimensions(handle);
    std::cout << "SVG dimensions: " << width << "x" << height << "\n";

    // Calculate the scale factor based on the target width
    gdouble scale_factor = target_width / width;

    // Create a surface and context to render to
    cairo_surface_t* surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, target_width, height * scale_factor);
    if (cairo_surface_status(surface) != CAIRO_STATUS_SUCCESS) {
        throw std::runtime_error("[Cairo] Error: Failed to create Cairo surface!");
    }
    cairo_t* cr = cairo_create(surface);
    if (cairo_status(cr) != CAIRO_STATUS_SUCCESS) {
        throw std::runtime_error(std::format("[Cairo] Error:  Cairo context is in an error state '{}'!", cairo_status_to_string(cairo_status(cr))));
    }

    // Apply scaling to the cairo context
    cairo_scale(cr, scale_factor, scale_factor);

    // Create a RsvgRectangle and render the document
    RsvgRectangle rect = {0, 0, width, height};  // Define the area to render
    rsvg_handle_render_document(handle, cr, &rect, NULL);

    // Write the output image
    std::filesystem::path temp_file = std::filesystem::temp_directory_path() / "tempfile.png";
    cairo_surface_write_to_png(
        surface,
        #ifdef _WIN32
        pathToUtf8(temp_file).c_str()
        #else
        temp_file.c_str()
        #endif
    );

    // Clean up
    cairo_destroy(cr);
    cairo_surface_destroy(surface);
    g_object_unref(handle);

    return temp_file;
}
