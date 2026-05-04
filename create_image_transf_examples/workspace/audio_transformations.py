## This script requires docker and the docker image : "ducksouplab/debian-gstreamer:deb12-with-plugins-cuda12.2-gst1.28.0"
## Create a docker account, if you are using Mac or windows, install docker desktop and login
## pull the image : docker pull "ducksouplab/debian-gstreamer:deb12-with-plugins-cuda12.2-gst1.28.0"
# ## docker pull "ducksouplab/debian-gstreamer:deb12-with-plugins-cuda12.2-gst1.28.0"
## Execute inside folder : python3 audio_transformations.py

import os
import sys
import subprocess

IMAGE = "ducksouplab/debian-gstreamer:deb12-with-plugins-cuda12.2-gst1.28.0"

# ==========================================
# 1. GUARDED GSTREAMER IMPORTS
# ==========================================
# We only import GStreamer if we are INSIDE Docker. 
# This prevents the script from crashing on your host machine 
# if your host doesn't have GStreamer installed.
if os.environ.get("INSIDE_DOCKER") == "1":
    import gi
    gi.require_version('Gst', '1.0')
    from gi.repository import Gst, GLib
    Gst.init(sys.argv)

# ==========================================
# 2. AUDIO TRANSFORMATION LOGIC
# ==========================================
def apply_audio_filter(input_file, output_file, plugin_string, name):
    """Builds and runs an audio pipeline, catching and printing any errors."""
    pipeline_str = (
        f"filesrc location={input_file} ! "
        f"wavparse ! "
        f"audioconvert ! "
        f"audioresample ! "
        f"{plugin_string} ! "
        f"audioconvert ! "
        f"audioresample ! "
        f"wavenc ! "
        f"filesink location={output_file}"
    )
    
    print(f"\n--- Testing: {name} ---")
    print(f"Pipeline: {plugin_string}")
    
    try:
        pipeline = Gst.parse_launch(pipeline_str)
    except GLib.Error as e:
        print(f"❌ FAILED: Plugin not found or invalid syntax.")
        print(f"   Reason: {e}")
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
            print(f"❌ FAILED during execution.")
            print(f"   Reason: {err.message}")
        elif msg.type == Gst.MessageType.EOS:
            print(f"✅ SUCCESS: Saved as {output_file}")

    pipeline.set_state(Gst.State.NULL)


def run_gstreamer_batch():
    """The main logic executed inside the container."""
    input_audio = "in.wav"
    
    if not os.path.exists(input_audio):
        print(f"CRITICAL ERROR: Could not find '{input_audio}'. Please add it to the folder.")
        sys.exit(1)

    transformations = {
        "pitch_deep": ("Deep Voice (Standard)", "pitch pitch=0.7"),
        "pitch_high": ("High Voice (Standard)", "pitch pitch=1.3"),
        "compressor": ("Flat Affect (Compressor)", "audiodynamic mode=compressor threshold=0.2 ratio=0.1"),
        "expander": ("High Expressivity (Expander)", "audiodynamic mode=expander threshold=0.1 ratio=3.0"),
        "lowpass": ("Hearing Loss (Low Pass)", "audiocheblimit mode=low-pass cutoff=1500"),
        "telephone": ("Telephone Filter (Bandpass)", "audiochebband lower-frequency=300 upper-frequency=3400"),
        "echo": ("Delayed Echo", "audioecho delay=400000000 intensity=0.6 feedback=0.4"),
        "reverb": ("Cathedral Reverb", "freeverb room-size=0.8"),
        "rubberband": ("Independent Formant Shift", "breakfastquay-com-rdf-lv2-rubberband-mono semitones=-2 formant=true"),
        "bitcrusher": ("Bitcrusher (Audio Degradation)", "calf-sourceforge-net-plugins-Crusher"),
        "vocoder": ("Robotic Vocoder", "drobilla-net-plugins-mda-Vocoder"),
        "autotune": ("Auto-Tune (Authenticity)", "gareus-org-oss-lv2-fat1 corr=1.0 filter=0.02"),
        "deesser": ("Sibilance Reduction (De-Esser)", "calf-sourceforge-net-plugins-Deesser threshold=0.12 ratio=3.0"),
        "exciter": ("Vocal Presence/Air (Exciter)", "calf-sourceforge-net-plugins-Exciter amount=2.0 drive=8.5"),
        "gate": ("Silence Background Noise (Gate)", "calf-sourceforge-net-plugins-Gate threshold=0.05 attack=10.0 release=150.0"),
        "ringmod": ("Dalek/Sci-Fi Voice (Ring Modulator)", "calf-sourceforge-net-plugins-RingModulator mod-amount=1.0"),
        "multichorus": ("Thickened Voice (MultiChorus)", "calf-sourceforge-net-plugins-MultiChorus voices=4 min-delay=5.0 mod-depth=2.0"),
        "detune": ("Disorienting Stereo (Detune)", "drobilla-net-plugins-mda-Detune detune=1.0 mix=0.5"),
        "overdrive": ("Megaphone/Blown Speaker (Overdrive)", "drobilla-net-plugins-mda-Overdrive drive=0.8 muffle=0.4"),
        "leslie": ("Vintage Warble (Leslie Cabinet)", "drobilla-net-plugins-mda-Leslie")
    }

    print("Starting DuckSoup Audio Transformation Batch Test...")
    
    for suffix, (name, plugin_str) in transformations.items():
        output_audio = f"audio_out/out_{suffix}.wav"
        apply_audio_filter(input_audio, output_audio, plugin_str, name)

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