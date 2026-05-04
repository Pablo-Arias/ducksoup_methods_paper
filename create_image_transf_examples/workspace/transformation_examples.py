## This script requires docker and the docker image : "ducksouplab/debian-gstreamer:deb12-with-plugins-cuda12.2-gst1.28.0"
## Create a docker account, if you are using Mac or windows, install docker desktop and login
## pull the image : docker pull "ducksouplab/debian-gstreamer:deb12-with-plugins-cuda12.2-gst1.28.0"
## Execute inside folder : python3 transformation_examples.py

import os
import sys
import subprocess

IMAGE = "ducksouplab/debian-gstreamer:deb12-with-plugins-cuda12.2-gst1.28.0"

# ==========================================
# 1. GUARDED GSTREAMER IMPORTS
# ==========================================
# We only import GStreamer if we are INSIDE Docker. 
if os.environ.get("INSIDE_DOCKER") == "1":
    import gi
    gi.require_version('Gst', '1.0')
    from gi.repository import Gst, GLib
    Gst.init(sys.argv)

# ==========================================
# 2. IMAGE TRANSFORMATION LOGIC
# ==========================================
def apply_gstreamer_filter(input_file, output_file, plugin_string):
    """Builds and runs a video/image pipeline, catching and printing any errors."""
    pipeline_str = (
        f"filesrc location={input_file} ! "
        f"jpegdec ! "
        f"videoconvert ! "
        f"{plugin_string} ! "
        f"videoconvert ! "
        f"jpegenc ! "
        f"filesink location={output_file}"
    )
    
    print(f"Running: {plugin_string} -> {output_file}")
    
    try:
        pipeline = Gst.parse_launch(pipeline_str)
    except GLib.Error as e:
        print(f"❌ Failed to parse pipeline for {plugin_string}: {e}")
        return

    pipeline.set_state(Gst.State.PLAYING)
    
    bus = pipeline.get_bus()
    msg = bus.timed_pop_filtered(
        Gst.CLOCK_TIME_NONE, 
        Gst.MessageType.ERROR | Gst.MessageType.EOS
    )
    
    if msg:
        if msg.type == Gst.MessageType.ERROR:
            err, debug = msg.parse_error()
            print(f"❌ Error from element {msg.src.get_name()}: {err.message}")
        elif msg.type == Gst.MessageType.EOS:
            print(f"✅ Successfully created {output_file}")

    pipeline.set_state(Gst.State.NULL)


def run_gstreamer_batch():
    """The main logic executed inside the container."""
    input_image = "in.jpg" 
    
    if not os.path.exists(input_image):
        print(f"CRITICAL ERROR: Could not find '{input_image}'. Please add it to the folder.")
        sys.exit(1)

    # CRITICAL FIX: Ensure the output directory exists so filesink doesn't crash
    os.makedirs("imgs", exist_ok=True)
    
    transformations = {
        # Original working plugins
        "videobalance": "videobalance saturation=2.0 hue=0.5", 
        "exclusion": "exclusion", 
        "agingtv": "agingtv", 
        "smooth": "smooth", 
        "mirror": "videoflip method=horizontal-flip", 
        "coloreffects": "coloreffects preset=sepia", 
        "chromahold": "chromahold target-r=255 target-g=0 target-b=0 tolerance=50", 
        "segmentation": "alpha method=custom", 
        
        # Face plugins
        "facedetect": "facedetect display=true", 
        "faceblur": "faceblur",
        # CRITICAL FIX: Made the dictionary keys unique
        #"faceoverlay_default": "faceoverlay", 
        #"faceoverlay_mask": "faceoverlay location=mask.svg",
        
        # New psychological / experimental plugins
        "edgedetect": "edgedetect", 
        "textoverlay": 'textoverlay text="Cooperative" valignment=top halignment=center font-desc="Sans, 48"', 
        "timeoverlay": "timeoverlay valignment=bottom halignment=right", 
        "videocrop": "videocrop top=50 left=50 right=50 bottom=50", 
        "aspectratiocrop": "aspectratiocrop aspect-ratio=1/1", 
        "gaussianblur": "gaussianblur sigma=4.0", 
        "vertical_flip": "videoflip method=vertical-flip",
        "edgetv": "edgetv",
        "grayscale": "videobalance saturation=0.0",
        "radioactv": "radioactv",

        # Morphological / Geometric distortions
        "bulge": "bulge zoom=1.3", 
        "pinch": "pinch intensity=0.3",
        "twirl": "twirl angle=0.5",
        "fisheye": "fisheye",
        "solarize": "solarize threshold=60"
    }

    print("Starting DuckSoup Image Transformation Batch Test...")
    
    for name, plugin_str in transformations.items():
        output_image = f"imgs/out_{name}.jpg"
        apply_gstreamer_filter(input_image, output_image, plugin_str)
        
    print("\nBatch test complete!")


# ==========================================
# 3. ROUTER (HOST VS DOCKER)
# ==========================================
def main():
    # If the environment variable isn't set, we are on the Host Machine.
    if os.environ.get("INSIDE_DOCKER") != "1":
        print(f"🔍 Checking for Docker image: {IMAGE}")
        
        # Check if image exists locally
        inspect = subprocess.run(
            ["docker", "image", "inspect", IMAGE],
            stdout=subprocess.DEVNULL, 
            stderr=subprocess.DEVNULL
        )
        
        if inspect.returncode != 0:
            print(f"⚠️ Image not found locally. Pulling {IMAGE}...")
            pull = subprocess.run(["docker", "pull", IMAGE])
            if pull.returncode != 0:
                print("❌ Failed to pull image. Exiting.")
                sys.exit(1)
        
        print("🚀 Launching Docker container...\n")
        
        # Build the docker run command
        script_name = os.path.basename(sys.argv[0])
        cmd = [
            "docker", "run", "--rm", "-it",
            "-e", "INSIDE_DOCKER=1",           # Set the flag so the script knows it's inside Docker
            "-v", f"{os.getcwd()}:/workspace", # Mount current directory
            "-w", "/workspace",                # Set working directory
            IMAGE,                             # The image to use
            "python3", script_name             # Tell Docker to run THIS exact script
        ]
        
        # Replace the current python process with the docker command
        sys.exit(subprocess.call(cmd))
        
    else:
        # If the environment variable IS set, we are inside Docker. Run the logic!
        run_gstreamer_batch()

if __name__ == '__main__':
    main()