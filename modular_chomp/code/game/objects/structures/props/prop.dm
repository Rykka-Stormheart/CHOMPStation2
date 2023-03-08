/*
 * Folder for adding our own props.
 * Not going to separate this out into multiple files yet.
*/

// APCs and power-related machinery/items.
/obj/structure/prop/machinery/power/apc
	name = "area power controller"
	desc = "A control terminal for the area electrical systems."
	icon = 'icons/obj/power.dmi'
	icon_state = "apc0"
	density = FALSE // Not dense, you can pass through APCs + cables

/obj/structure/prop/machinery/power/apc/New()
	..()
	if (!pixel_x && !pixel_y)
		offset_apc()
	update_icon()
	var/area/a = get_area(src)
	name = "[a.name] APC"

/obj/structure/prop/machinery/power/apc/update_icon()
	cut_overlays()
	var/list/new_overlays = list()
	new_overlays += mutable_appearance(icon, "apcox-1")
	new_overlays += emissive_appearance(icon, "apcox-1")
	new_overlays += mutable_appearance(icon, "apco3-2")
	new_overlays += emissive_appearance(icon, "apco3-2")
	new_overlays += mutable_appearance(icon, "apco0-1")
	new_overlays += emissive_appearance(icon, "apco0-1")
	new_overlays += mutable_appearance(icon, "apco1-1")
	new_overlays += emissive_appearance(icon, "apco1-1")
	new_overlays += mutable_appearance(icon, "apco2-1")
	new_overlays += emissive_appearance(icon, "apco2-1")
	add_overlay(new_overlays)
	set_light(l_range = 2, l_power = 0.25, l_color = "#82FF4C")
	set_light_on(TRUE)

/obj/structure/prop/machinery/power/apc/proc/offset_apc()
	pixel_x = (dir & 3) ? 0 : (dir == 4 ? 26 : -26)
	pixel_y = (dir & 3) ? (dir == 1 ? 26 : -26) : 0

/obj/structure/prop/machinery/power/apc/critical

/obj/structure/prop/machinery/power/apc/high

/obj/structure/prop/machinery/power/apc/super

/obj/structure/prop/machinery/power/apc/super/critical

/obj/structure/prop/machinery/power/apc/hyper

/obj/structure/prop/machinery/power/apc/alarms_hidden

/obj/structure/prop/machinery/power/apc/angled
	icon = 'icons/obj/wall_machines_angled.dmi'

/obj/structure/prop/machinery/power/apc/angled/hidden

/obj/structure/prop/machinery/power/apc/angled/offset_apc()
	pixel_x = (dir & 3) ? 0 : (dir == 4 ? 24 : -24)
	pixel_y = (dir & 3) ? (dir == 1 ? 20 : -20) : 0

// Fire alarms, Air Alarms.
// These exist solely to enable easier copy/paste.
/obj/structure/prop/machinery/firealarm
	name = "fire alarm"
	desc = "<i>\"Pull this in case of emergency\"</i>. Thus, keep pulling it forever."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire"
	layer = ABOVE_WINDOW_LAYER
	blocks_emissive = FALSE
	vis_flags = VIS_HIDE // They have an emissive that looks bad in openspace due to their wall-mounted nature
	anchored = TRUE
	unacidable = TRUE
	density = FALSE

/obj/structure/prop/machinery/firealarm/New()
	..()
	if (!pixel_x && !pixel_y)
		offset_alarm()
	update_icon()

/obj/structure/prop/machinery/firealarm/proc/offset_alarm()
	pixel_x = (dir & 3) ? 0 : (dir == 4 ? 26 : -26)
	pixel_y = (dir & 3) ? (dir == 1 ? -26 : 26) : 0

/obj/structure/prop/machinery/firealarm/update_icon()
	cut_overlays()
	. = list()
	. += mutable_appearance(icon, "fire0")
	. += emissive_appearance(icon, "fire0")
	. += mutable_appearance(icon, "overlay_green")
	. += emissive_appearance(icon, "overlay_green")
	add_overlay(.)
	set_light(l_range = 2, l_power = 0.25, l_color = "#00ff00")

/obj/structure/prop/machinery/firealarm/alarms_hidden

/obj/structure/prop/machinery/firealarm/angled
	icon = 'icons/obj/wall_machines_angled.dmi'

/obj/structure/prop/machinery/firealarm/angled/hidden

/obj/structure/prop/machinery/firealarm/angled/offset_alarm()
	pixel_x = (dir & 3) ? 0 : (dir == 4 ? 20 : -20)
	pixel_y = (dir & 3) ? (dir == 1 ? -18 : 21) : 0


/obj/structure/prop/machinery/alarm
	name = "alarm"
	desc = "Used to control various station atmospheric systems. The light indicates the current air status of the area."
	icon = 'icons/obj/monitors_vr.dmi' //VOREStation Edit - Other icons
	icon_state = "alarm_0"
	layer = ABOVE_WINDOW_LAYER
	vis_flags = VIS_HIDE // They have an emissive that looks bad in openspace due to their wall-mounted nature
	anchored = TRUE
	unacidable = TRUE
	density = FALSE

/obj/structure/prop/machinery/alarm/New()
	..()
	if (!pixel_x && !pixel_y)
		offset_airalarm()
	update_icon()
	var/area/a = get_area(src)
	name = "[a.name] Air Alarm"

/obj/structure/prop/machinery/alarm/update_icon()
	cut_overlays()
	add_overlay(mutable_appearance(icon, "alarm_ov0"))
	add_overlay(emissive_appearance(icon, "alarm_ov0"))
	set_light(l_range = 2, l_power = 0.25, l_color = "#03A728")
	set_light_on(TRUE)

/obj/structure/prop/machinery/alarm/proc/offset_airalarm()
	pixel_x = (dir & 3) ? 0 : (dir == 4 ? -26 : 26)
	pixel_y = (dir & 3) ? (dir == 1 ? -26 : 26) : 0

/obj/structure/prop/machinery/alarm/nobreach

/obj/structure/prop/machinery/alarm/monitor

/obj/structure/prop/machinery/alarm/alarms_hidden

/obj/structure/prop/machinery/alarm/angled
	icon = 'icons/obj/wall_machines_angled.dmi'

/obj/structure/prop/machinery/alarm/angled/hidden

/obj/structure/prop/machinery/alarm/angled/offset_airalarm()
	pixel_x = (dir & 3) ? 0 : (dir == 4 ? -21 : 21)
	pixel_y = (dir & 3) ? (dir == 1 ? -18 : 20) : 0

/obj/structure/prop/machinery/alarm/freezer

// Camera Replacement;
/obj/structure/prop/machinery/camera
	name = "security camera"
	desc = "It's used to monitor rooms."
	icon = 'icons/obj/monitors_vr.dmi' //VOREStation Edit - New Icons
	icon_state = "camera"
	plane = MOB_PLANE
	layer = ABOVE_MOB_LAYER
	var/c_tag = "null" // Nonexistant var, does nada for our props, but cuts down on work having to re-convert.
	density = FALSE

// NS-specific subtypes;
/obj/structure/prop/machinery/camera/network/command

/obj/structure/prop/machinery/camera/network/research

/obj/structure/prop/machinery/camera/network/medbay

/obj/structure/prop/machinery/camera/network/prison

/obj/structure/prop/machinery/camera/network/thunder

/obj/structure/prop/machinery/camera/network/northern_star

/obj/structure/prop/machinery/camera/network/civilian

/obj/structure/prop/machinery/camera/network/security

/obj/structure/prop/machinery/atmospherics
	density = FALSE
	layer = ATMOS_LAYER
	plane = PLATING_PLANE

// Vents/Pipes + Scrubbers/Pumps
/obj/structure/prop/machinery/atmospherics/unary/vent_pump
	icon = 'icons/atmos/vent_pump.dmi'
	icon_state = "out"

	name = "Air Vent"
	desc = "Has a valve and pump attached to it"
	var/id_tag

/obj/structure/prop/machinery/atmospherics/unary/vent_pump/New()
	..()
	var/area/a = get_area(src)
	name = "[a.name] Air Vent"

/obj/structure/prop/machinery/atmospherics/unary/vent_pump/on

/obj/structure/prop/machinery/atmospherics/unary/vent_pump/high_volume
	name = "Large Air Vent"

/obj/structure/prop/machinery/atmospherics/unary/vent_scrubber
	icon = 'icons/atmos/vent_scrubber.dmi'
	icon_state = "on"

	name = "Air Scrubber"
	desc = "Has a valve and pump attached to it"
	var/id_tag

/obj/structure/prop/machinery/atmospherics/unary/vent_scrubber/New()
	..()
	var/area/a = get_area(src)
	name = "[a.name] Air Scrubber"

/obj/structure/prop/machinery/atmospherics/unary/vent_scrubber/on
