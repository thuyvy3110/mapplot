from moviepy.editor import *

plist = [f"m_{x}.png" for x in list(range(1, 68))]
anim = ImageSequenceClip(plist, fps = 20)
anim.write_gif("gif_map.gif") # or anim.write_videofile("vid_map.mp4")
