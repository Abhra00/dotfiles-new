-- ┏┓┓ ┏┏┓┓┏┳┳┳┓┏┓
-- ┗┓┃┃┃┣┫┗┫┃┃┃┃┃┓
-- ┗┛┗┻┛┛┗┗┛┻┛ ┗┗┛
--
-- General config
swayimg.set_mode("viewer")
swayimg.enable_antialiasing(true)
swayimg.enable_decoration(true)
swayimg.enable_overlay(false)
swayimg.set_dnd_button("MouseRight")

-- Image list configuration
swayimg.imagelist.set_order("numeric")
swayimg.imagelist.enable_reverse(false)
swayimg.imagelist.enable_recursive(false)
swayimg.imagelist.enable_adjacent(false)

-- Text overlay configuration
swayimg.text.set_font("Iosevkeley Mono")
swayimg.text.set_size(24)
swayimg.text.set_padding(10)
swayimg.text.set_foreground(0xffe5c9a0) -- fg
swayimg.text.set_background(0x00141210) -- bg
swayimg.text.set_shadow(0xff0b0a09) -- black
swayimg.text.set_timeout(5)
swayimg.text.set_status_timeout(3)

-- Image viewer mode
swayimg.viewer.set_default_scale("optimal")
swayimg.viewer.set_default_position("center")
swayimg.viewer.set_drag_button("MouseLeft")
swayimg.viewer.set_window_background(0xff141210) -- bg
swayimg.viewer.set_image_chessboard(20, 0xff3f3933, 0xff26221e) -- nontext / selection
swayimg.viewer.enable_centering(true)
swayimg.viewer.enable_loop(true)
swayimg.viewer.limit_preload(1)
swayimg.viewer.set_mark_color(0xffe5c9a0) -- fg

swayimg.viewer.set_text("topleft", {
	"File: {name}",
	"Format: {format}",
	"File size: {sizehr}",
	"File time: {time}",
	"EXIF date: {meta.Exif.Photo.DateTimeOriginal}",
	"EXIF camera: {meta.Exif.Image.Model}",
})

swayimg.viewer.set_text("topright", {
	"Image: {list.index} of {list.total}",
	"Frame: {frame.index} of {frame.total}",
	"Size: {frame.width}x{frame.height}",
})

swayimg.viewer.set_text("bottomleft", {
	"Scale: {scale}",
})

-- Key and mouse bindings in viewer mode
swayimg.viewer.on_key("Escape", function()
	swayimg.exit()
end)

swayimg.viewer.on_key("Left", function()
	local wnd = swayimg.get_window_size()
	local pos = swayimg.viewer.get_position()
	swayimg.viewer.set_abs_position(math.floor(pos.x + wnd.width / 10), pos.y)
end)

swayimg.viewer.on_mouse("Ctrl-ScrollUp", function()
	local pos = swayimg.get_mouse_pos()
	local scale = swayimg.viewer.get_scale()
	scale = scale + scale / 10
	swayimg.viewer.set_abs_scale(scale, pos.x, pos.y)
end)

-- Slide show mode
swayimg.slideshow.set_timeout(5)
swayimg.slideshow.set_default_scale("fit")
swayimg.slideshow.set_window_background("auto")
swayimg.slideshow.set_text("topleft", { "{name}" })

-- Gallery mode
swayimg.gallery.set_aspect("fill")
swayimg.gallery.set_thumb_size(200)
swayimg.gallery.set_padding_size(5)
swayimg.gallery.set_border_size(1)
swayimg.gallery.set_border_color(0xff7f91b2) -- blue
swayimg.gallery.set_selected_scale(1.15)
swayimg.gallery.set_selected_color(0xff26221e) -- selection
swayimg.gallery.set_unselected_color(0xff141210) -- bg
swayimg.gallery.set_window_color(0xff0b0a09) -- black
swayimg.gallery.limit_cache(100)
swayimg.gallery.enable_preload(false)
swayimg.gallery.enable_pstore(false)

swayimg.gallery.set_text("topleft", {
	"File: {name}",
})

swayimg.gallery.set_text("topright", {
	"{list.index} of {list.total}",
})

-- Key and mouse bindings in gallery mode
swayimg.gallery.on_key("Return", function()
	swayimg.set_mode("viewer")
end)

swayimg.gallery.on_key("Left", function()
	swayimg.gallery.switch_image("left")
end)

-- Other key binding examples
swayimg.slideshow.on_key("Delete", function()
	local image = swayimg.slideshow.get_image()
	os.remove(image.path)
	swayimg.text.set_status("File " .. image.path .. " removed")
end)

swayimg.gallery.on_image_change(function()
	local image = swayimg.gallery.get_image()
	swayimg.set_title("Gallery: " .. image.path)
end)

swayimg.gallery.on_key("Ctrl-p", function()
	local entries = swayimg.imagelist.get()
	for _, entry in ipairs(entries) do
		if entry.mark then
			print(entry.path)
		end
	end
end)
