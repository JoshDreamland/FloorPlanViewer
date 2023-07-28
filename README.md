# Floorplan Viewer

This is a floorplan viewer widget made using **Leaflet.js**. Support them
(and the country of Ukraine) at [leafletjs.com](https://leafletjs.com/).

Included in this repository are two files:

* `split-images-npo2.bash`: A Bash script that calls out to ImageMagick
  (through the `convert` tool) to cut a target image (or images) into 256-pixel
  chunks. These are the default size used by Leaflet, though you can tweak both
  figures in the included files.

* `index.htm`: The actual Leaflet viewer. Leaflet itself is obtained from
  unpkg.com as is generally recommended. The floor data must be updated to
  refer to the images you wish to display. The JSON for this is printed by
  the `split-images-npo2.bash` script. You can also update the `MAIN_FLOOR`
  and `OPACITY_STEPS` constants to suit your needs. By default, we assume
  there is a basement below the main floor, and that you wish to be able
  to smoothly interpolate between floors (to verify support/infra alignment).

## Demo

You can view the demo included with this repository
[here](https://JoshDreamland.github.io/FloorPlanViewer).

## Why use this?

Use this to display a floorplan or other layered diagram where the ability to
flip through various layers of the same diagram is required. Especially use this
if you want to be able to interpolate between adjacent layers.

In particular, I like this tool because it's simple and mobile-friendly.

## Why not use this?

Don't use this if you have a very small diagram or need to be able to toggle
independent feature layers. This UI is overkill for the former and not at all
tooled for the latter—I use a slider to choose one or two layers, not a list
of checkboxes. Feel free to contribute a list of checkboxes!

Note that the sample floorplan that ships with this tool is from ArchDaily
(see link below) and is, in fact, quite small. It does a relatively poor job
showing off this tool, but I didn't want to check enormous images into Git.

## Quick setup

You can build the demo from scratch yourself by deleting the `floors` folder
from the repository and running this command:

```bash
./split-image-npo2.bash \
    sample/F0-basement-floor-plan.jpg \
    sample/F1-ground-floor-plan.jpg \
    sample/F2-first-floor-plan.jpg \
    sample/F3-second-floor-plan.jpg
```

When the command completes, it will print JSON for you to copy into
`index.html`. 

## License
I am releasing this code into the public domain. Most of it is Leaflet.js,
and the rest was pilfured from CSS Tricks or similar sources.

The included sample is the "House of Terraces / Architecture Paradigm",
17 Feb 2022. Accessed 28 Jul 2023 from
[ArchDaily](https://www.archdaily.com/977060/house-of-terraces-architecture-paradigm),
ISSN 0719-8884.
