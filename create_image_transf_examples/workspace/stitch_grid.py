import os
import math
import textwrap
import matplotlib.pyplot as plt
import matplotlib.image as mpimg

def main():
    # Dictionary mapping the filenames to clean, publication-ready labels
    images_to_plot = {
        "in.jpg": "Original (No Transformation)",
        "out_videobalance.jpg": "Video Balance (Saturation/Hue)",
        "out_exclusion.jpg": "Exclusion (Color Inversion)",
        "out_agingtv.jpg": "Aging TV (Vintage/Noise)",
        "out_smooth.jpg": "Smooth (Spatial Blur)",
        "out_mirror.jpg": "Mirror (Horizontal Flip)",
        "out_coloreffects.jpg": "Color Effects (Sepia)",
        #"out_chromahold.jpg": "Chroma Hold (Isolate Red)",
        "out_segmentation.jpg": "Segmentation (Alpha Custom)",
        "out_facedetect.jpg": "Face Detect (Bounding Ellipse)",
        "out_faceblur.jpg": "Face Blur (Anonymization)",
        "out_edgedetect.jpg": "Edge Detect (Canny Features)",
        "out_textoverlay.jpg": "Text Overlay (Cognitive Priming)",
        "out_timeoverlay.jpg": "Time Overlay (Time Pressure)",
        "out_videocrop.jpg": "Video Crop (Zoom/Proximity)",
        "out_aspectratiocrop.jpg": "Aspect Ratio Crop (1:1)",
        "out_gaussianblur.jpg": "Gaussian Blur (Visual Degradation)",
        "out_vertical_flip.jpg": "Vertical Flip (Face Inversion)",
        "out_edgetv.jpg": "Edge TV (Kinematic Focus)",
        "out_grayscale.jpg": "Grayscale (Colorblindness Sim.)",
        "out_radioactv.jpg": "Radioactive (Sensory Disruption)",
        "out_bulge.jpg": "Bulge (Morphological Distention)",
        "out_pinch.jpg": "Pinch (Morphological Shrinking)",
        "out_twirl.jpg": "Twirl (Morphological Twisting)",
        "out_fisheye.jpg": "Fisheye (Optical Distortion)",
        "out_solarize.jpg": "Solarize (High Contrast Negative)"
    }

    # Filter out any images that didn't generate properly
    available_images = {k: v for k, v in images_to_plot.items() if os.path.exists(k)}
    
    num_images = len(available_images)
    print(f"Found {num_images} images to stitch.")

    # Determine grid size
    cols = 5
    rows = math.ceil(num_images / cols)

    # UPDATED: Increased figure size slightly to give more room per column
    fig, axes = plt.subplots(rows, cols, figsize=(4 * cols, 4.5 * rows))
    axes = axes.flatten()

    for idx, (filename, label) in enumerate(available_images.items()):
        ax = axes[idx]
        try:
            img = mpimg.imread(filename)
            ax.imshow(img)
            
            # UPDATED: Wrap the text after 22 characters so it doesn't overlap horizontally
            wrapped_label = "\n".join(textwrap.wrap(label, width=15))
            ax.set_title(wrapped_label, fontsize=24, pad=12, fontweight='bold', ha='center')
        except Exception as e:
            print(f"Error loading {filename}: {e}")
        
        # Remove axis ticks and borders for a clean look
        ax.axis('off')

    # Turn off any unused subplots in the grid
    for i in range(num_images, len(axes)):
        axes[i].axis('off')

    # UPDATED: Added explicit width and height padding between subplots
    plt.tight_layout(w_pad=2.0, h_pad=2.0)
    
    # Save as a high-res PDF and PNG for the manuscript
    output_pdf = "imgs/Figure_DuckSoup_Transformations.pdf"
    output_png = "imgs/Figure_DuckSoup_Transformations.png"
    
    plt.savefig(output_pdf, dpi=300, bbox_inches='tight')
    plt.savefig(output_png, dpi=300, bbox_inches='tight')
    
    print(f"Successfully saved grid to {output_pdf} and {output_png}!")

if __name__ == '__main__':
    main()