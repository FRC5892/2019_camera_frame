#camera_frame

Our web-based dashboard for the 2019 season.

We decided to make our own dashboard instead of continuing to use Shuffleboard for the following reasons:
- **Better camera display.** For whatever reason, Shuffleboard's display of camera feeds is really crappy. The feed displays fine from the web CameraServer stream, so I just copied that image tag into this and it worked fine. ~~Also our practice camera is sideways and the driver couldn't give us feedback on how well it worked until we could rotate the feed~~
- **Auton not necessary.** Because we are focusing on driver-assist code during operator control rather than a dedicated autonomous routine for the Sandstorm, we don't need the ability to choose an autonomous from the dropdown, simplifying things.
- **Larger fonts.** Obviously we could read the battery voltage from the Driver Station and post everything else to NetworkTables/Shuffleboard, but this improves readability for the drive team.
- **Having our team logo on the operator console.** And really, who needs anything else? ~~Yes I am aware you can put images on Shuffleboard don't @ me~~
