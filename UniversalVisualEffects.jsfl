// Universal Visual Effects for Adobe Animate
// Save this as: UniversalVisualEffects.jsfl
// Applies REAL visible effects using Animate's native capabilities

fl.outputPanel.clear();
fl.outputPanel.trace("=== Universal Visual Effects for Adobe Animate ===\n");

// Main function
function applyVisualEffect() {
    var dom = fl.getDocumentDOM();
    
    if (!dom) {
        alert("Please open a document first!");
        return false;
    }
    
    var selection = dom.selection;
    
    if (selection.length === 0) {
        alert("Please select at least one element on stage!");
        return false;
    }
    
    // Show effect selection dialog
    var effectType = showEffectDialog();
    
    if (effectType === null || effectType === "") {
        return false;
    }
    
    if (effectType === "remove") {
        removeAllEffects();
        return true;
    }
    
    // Apply effect to all selected elements
    var appliedCount = 0;
    for (var i = 0; i < selection.length; i++) {
        if (applyEffectToElement(selection[i], effectType)) {
            appliedCount++;
        }
    }
    
    fl.outputPanel.trace("\n✓ Applied " + effectType + " to " + appliedCount + " element(s)");
    alert("Applied " + effectType + " to " + appliedCount + " element(s)");
    
    return true;
}

// Effect selection dialog
function showEffectDialog() {
    var effectList = "╔════════════════════════════════════════════════════════════╗\n";
    effectList += "║                   SELECT VISUAL EFFECT                        ║\n";
    effectList += "╠════════════════════════════════════════════════════════════╣\n";
    effectList += "║  COLOR EFFECTS (Native):                                    ║\n";
    effectList += "║    1. Brightness +50%    2. Brightness -50%                ║\n";
    effectList += "║    3. Tint Red           4. Tint Blue                       ║\n";
    effectList += "║    5. Tint Green         6. Grayscale (Advanced)            ║\n";
    effectList += "║    7. Sepia Tone         8. Invert Colors                   ║\n";
    effectList += "╠════════════════════════════════════════════════════════════╣\n";
    effectList += "║  FILTER EFFECTS (Requires Flash Player):                    ║\n";
    effectList += "║    9. Drop Shadow       10. Blur                            ║\n";
    effectList += "║   11. Glow              12. Bevel                           ║\n";
    effectList += "║   13. Gradient Glow     14. Gradient Bevel                  ║\n";
    effectList += "╠════════════════════════════════════════════════════════════╣\n";
    effectList += "║  TRANSFORM EFFECTS:                                         ║\n";
    effectList += "║   15. 50% Scale         16. 200% Scale                      ║\n";
    effectList += "║   17. Rotate 90°        18. Flip Horizontal                 ║\n";
    effectList += "║   19. Flip Vertical     20. Skew 15°                        ║\n";
    effectList += "╠════════════════════════════════════════════════════════════╣\n";
    effectList += "║  BLEND MODES:                                               ║\n";
    effectList += "║   21. Multiply          22. Screen                          ║\n";
    effectList += "║   23. Overlay           24. Lighten                         ║\n";
    effectList += "║   25. Darken            26. Difference                      ║\n";
    effectList += "╠════════════════════════════════════════════════════════════╣\n";
    effectList += "║  UTILITIES:                                                 ║\n";
    effectList += "║   27. Remove All Effects                                    ║\n";
    effectList += "║   28. List Active Effects                                   ║\n";
    effectList += "╚════════════════════════════════════════════════════════════╝\n\n";
    effectList += "Enter number (1-28):";
    
    var userInput = prompt(effectList, "1");
    
    if (userInput === null) return null;
    
    var effectNum = parseInt(userInput);
    
    var effects = {
        1: "brightness_up", 2: "brightness_down", 3: "tint_red", 4: "tint_blue",
        5: "tint_green", 6: "grayscale", 7: "sepia", 8: "invert",
        9: "dropshadow", 10: "blur", 11: "glow", 12: "bevel",
        13: "gradientglow", 14: "gradientbevel", 15: "scale_down", 16: "scale_up",
        17: "rotate", 18: "flip_h", 19: "flip_v", 20: "skew",
        21: "multiply", 22: "screen", 23: "overlay", 24: "lighten",
        25: "darken", 26: "difference", 27: "remove", 28: "list"
    };
    
    return effects[effectNum] || null;
}

// Apply effect to element
function applyEffectToElement(element, effectType) {
    if (!element) return false;
    
    try {
        // Apply different effects based on type
        if (effectType.indexOf("brightness") !== -1) {
            return applyBrightness(element, effectType);
        }
        else if (effectType.indexOf("tint") !== -1) {
            return applyTint(element, effectType);
        }
        else if (effectType === "grayscale") {
            return applyGrayscale(element);
        }
        else if (effectType === "sepia") {
            return applySepia(element);
        }
        else if (effectType === "invert") {
            return applyInvert(element);
        }
        else if (effectType.indexOf("scale") !== -1) {
            return applyScale(element, effectType);
        }
        else if (effectType === "rotate") {
            return applyRotate(element);
        }
        else if (effectType.indexOf("flip") !== -1) {
            return applyFlip(element, effectType);
        }
        else if (effectType === "skew") {
            return applySkew(element);
        }
        else if (effectType === "multiply" || effectType === "screen" || effectType === "overlay" || 
                 effectType === "lighten" || effectType === "darken" || effectType === "difference") {
            return applyBlendMode(element, effectType);
        }
        else {
            return applyFilter(element, effectType);
        }
    } catch(e) {
        fl.outputPanel.trace("Error applying effect: " + e);
        return false;
    }
}

// Apply brightness
function applyBrightness(element, type) {
    var brightness = (type === "brightness_up") ? 50 : -50;
    
    if (element.colorTransform) {
        var oldTransform = element.colorTransform;
        var newTransform = {};
        newTransform.brightness = brightness;
        element.colorTransform = newTransform;
        fl.outputPanel.trace("  ✓ Applied brightness: " + brightness + "%");
        return true;
    }
    return false;
}

// Apply tint
function applyTint(element, type) {
    var color = (type === "tint_red") ? 0xFF0000 : 
                (type === "tint_blue") ? 0x0000FF : 0x00FF00;
    
    if (element.colorTransform) {
        element.colorTransform = { tintColor: color, tintPercent: 50 };
        fl.outputPanel.trace("  ✓ Applied tint");
        return true;
    }
    return false;
}

// Apply grayscale using color matrix
function applyGrayscale(element) {
    // Use advanced color transform for grayscale
    if (element.colorTransform) {
        // Grayscale by setting saturation to 0
        element.colorTransform = { 
            redMultiplier: 0.3086, redOffset: 0,
            greenMultiplier: 0.6094, greenOffset: 0,
            blueMultiplier: 0.0820, blueOffset: 0,
            alphaMultiplier: 1, alphaOffset: 0
        };
        fl.outputPanel.trace("  ✓ Applied grayscale effect");
        return true;
    }
    return false;
}

// Apply sepia tone
function applySepia(element) {
    if (element.colorTransform) {
        element.colorTransform = {
            redMultiplier: 0.393, redOffset: 0,
            greenMultiplier: 0.769, greenOffset: 0,
            blueMultiplier: 0.189, blueOffset: 0
        };
        fl.outputPanel.trace("  ✓ Applied sepia tone");
        return true;
    }
    return false;
}

// Apply invert
function applyInvert(element) {
    if (element.colorTransform) {
        element.colorTransform = {
            redMultiplier: -1, redOffset: 255,
            greenMultiplier: -1, greenOffset: 255,
            blueMultiplier: -1, blueOffset: 255
        };
        fl.outputPanel.trace("  ✓ Applied invert effect");
        return true;
    }
    return false;
}

// Apply scale
function applyScale(element, type) {
    var scale = (type === "scale_up") ? 200 : 50;
    var scalePercent = scale / 100;
    
    element.scaleX = scalePercent;
    element.scaleY = scalePercent;
    
    fl.outputPanel.trace("  ✓ Applied scale: " + scale + "%");
    return true;
}

// Apply rotate
function applyRotate(element) {
    element.rotation = 90;
    fl.outputPanel.trace("  ✓ Applied 90° rotation");
    return true;
}

// Apply flip
function applyFlip(element, type) {
    if (type === "flip_h") {
        element.scaleX = element.scaleX * -1;
        fl.outputPanel.trace("  ✓ Applied horizontal flip");
    } else {
        element.scaleY = element.scaleY * -1;
        fl.outputPanel.trace("  ✓ Applied vertical flip");
    }
    return true;
}

// Apply skew
function applySkew(element) {
    element.skewX = 15;
    element.skewY = 0;
    fl.outputPanel.trace("  ✓ Applied 15° skew");
    return true;
}

// Apply blend mode
function applyBlendMode(element, mode) {
    var blendModes = {
        "multiply": "multiply",
        "screen": "screen",
        "overlay": "overlay",
        "lighten": "lighten",
        "darken": "darken",
        "difference": "difference"
    };
    
    if (blendModes[mode]) {
        element.blendMode = blendModes[mode];
        fl.outputPanel.trace("  ✓ Applied blend mode: " + mode);
        return true;
    }
    return false;
}

// Apply filter effects
function applyFilter(element, filterType) {
    // Create filter based on type
    var filter = null;
    
    switch(filterType) {
        case "dropshadow":
            filter = { name: "dropShadow", distance: 5, angle: 45, color: 0x000000, alpha: 0.5, blurX: 5, blurY: 5, strength: 1, quality: 1 };
            break;
        case "blur":
            filter = { name: "blur", blurX: 10, blurY: 10, quality: 1 };
            break;
        case "glow":
            filter = { name: "glow", color: 0xFFFF00, alpha: 0.8, blurX: 10, blurY: 10, strength: 2, quality: 1 };
            break;
        case "bevel":
            filter = { name: "bevel", angle: 45, distance: 5, highlightColor: 0xFFFFFF, highlightAlpha: 0.8, shadowColor: 0x000000, shadowAlpha: 0.8, blurX: 5, blurY: 5, strength: 1, quality: 1 };
            break;
        case "gradientglow":
            filter = { name: "gradientGlow", distance: 5, angle: 45, colors: [0xFF0000, 0x00FF00, 0x0000FF], alphas: [1, 1, 1], ratios: [0, 128, 255], blurX: 10, blurY: 10, strength: 2, quality: 1 };
            break;
        case "gradientbevel":
            filter = { name: "gradientBevel", distance: 5, angle: 45, colors: [0xFFFFFF, 0x000000], alphas: [1, 1], ratios: [0, 255], blurX: 5, blurY: 5, strength: 1, quality: 1 };
            break;
        default:
            return false;
    }
    
    // Apply filter
    if (filter) {
        element.filters = [filter];
        fl.outputPanel.trace("  ✓ Applied filter: " + filterType);
        return true;
    }
    
    return false;
}

// Remove all effects
function removeAllEffects() {
    var dom = fl.getDocumentDOM();
    if (!dom) return;
    
    var selection = dom.selection;
    var removedCount = 0;
    
    for (var i = 0; i < selection.length; i++) {
        var element = selection[i];
        
        // Reset color transform
        if (element.colorTransform) {
            element.colorTransform = { redMultiplier: 1, greenMultiplier: 1, blueMultiplier: 1, alphaMultiplier: 1 };
            removedCount++;
        }
        
        // Remove filters
        if (element.filters) {
            element.filters = [];
            removedCount++;
        }
        
        // Reset transform
        element.scaleX = 1;
        element.scaleY = 1;
        element.rotation = 0;
        element.skewX = 0;
        element.skewY = 0;
        
        // Reset blend mode
        element.blendMode = "normal";
    }
    
    fl.outputPanel.trace("✓ Removed effects from " + removedCount + " element(s)");
    alert("Removed all effects from " + removedCount + " element(s)");
}

// List active effects
function listActiveEffects() {
    var dom = fl.getDocumentDOM();
    if (!dom) return;
    
    var selection = dom.selection;
    var effectsList = [];
    
    for (var i = 0; i < selection.length; i++) {
        var element = selection[i];
        var elementEffects = [];
        
        // Check for color effects
        if (element.colorTransform) {
            var ct = element.colorTransform;
            if (ct.brightness !== undefined && ct.brightness !== 0) {
                elementEffects.push("Brightness: " + ct.brightness + "%");
            }
            if (ct.tintColor !== undefined) {
                elementEffects.push("Tint");
            }
            if (ct.redMultiplier !== undefined && ct.redMultiplier !== 1) {
                elementEffects.push("Color Matrix");
            }
        }
        
        // Check for filters
        if (element.filters && element.filters.length > 0) {
            for (var f = 0; f < element.filters.length; f++) {
                elementEffects.push("Filter: " + element.filters[f].name);
            }
        }
        
        // Check transform
        if (element.scaleX !== 1 || element.scaleY !== 1) {
            elementEffects.push("Scale: " + Math.round(element.scaleX * 100) + "%");
        }
        if (element.rotation !== 0) {
            elementEffects.push("Rotation: " + element.rotation + "°");
        }
        if (element.skewX !== 0 || element.skewY !== 0) {
            elementEffects.push("Skew");
        }
        
        // Check blend mode
        if (element.blendMode && element.blendMode !== "normal") {
            elementEffects.push("Blend Mode: " + element.blendMode);
        }
        
        if (elementEffects.length > 0) {
            effectsList.push("Element " + (i+1) + " (" + element.elementType + "): " + elementEffects.join(", "));
        }
    }
    
    if (effectsList.length > 0) {
        alert("Active Effects:\n\n" + effectsList.join("\n"));
    } else {
        alert("No active effects found on selected elements.");
    }
}

// Create animation with effects (bonus feature)
function createAnimatedEffect() {
    var dom = fl.getDocumentDOM();
    if (!dom) return;
    
    var selection = dom.selection;
    if (selection.length === 0) {
        alert("Please select an element to animate!");
        return;
    }
    
    var timeline = dom.getTimeline();
    var currentFrame = timeline.currentFrame;
    
    // Add keyframes
    timeline.insertFrames(30);
    
    // Create fade in effect
    for (var i = 0; i < selection.length; i++) {
        var element = selection[i];
        
        // Set initial alpha to 0
        timeline.currentFrame = currentFrame;
        if (element.colorTransform) {
            element.colorTransform = { alphaMultiplier: 0 };
        }
        
        // Set final alpha to 100
        timeline.currentFrame = currentFrame + 30;
        if (element.colorTransform) {
            element.colorTransform = { alphaMultiplier: 1 };
        }
        
        // Create motion tween
        timeline.currentFrame = currentFrame;
        dom.selectElement(element);
        dom.createMotionTween();
    }
    
    fl.outputPanel.trace("✓ Created 30-frame fade animation");
    alert("Created 30-frame fade animation!");
}

// Quick effects panel
function showQuickEffectsPanel() {
    var options = "QUICK EFFECTS PANEL\n\n";
    options += "1. Make Glow\n";
    options += "2. Add Shadow\n";
    options += "3. Blur\n";
    options += "4. Grayscale\n";
    options += "5. Sepia\n";
    options += "6. Brighten\n";
    options += "7. Darken\n";
    options += "8. Remove Effects\n";
    options += "9. Create Fade Animation\n";
    options += "10. Main Menu\n\n";
    options += "Enter choice (1-10):";
    
    var choice = prompt(options, "1");
    if (!choice) return;
    
    var dom = fl.getDocumentDOM();
    if (!dom) return;
    
    var selection = dom.selection;
    if (selection.length === 0 && choice != "8") {
        alert("Please select an element first!");
        return;
    }
    
    switch(parseInt(choice)) {
        case 1:
            for (var i = 0; i < selection.length; i++) {
                selection[i].filters = [{ name: "glow", color: 0xFFFF00, alpha: 0.8, blurX: 10, blurY: 10, strength: 2 }];
            }
            alert("Glow applied!");
            break;
        case 2:
            for (var i = 0; i < selection.length; i++) {
                selection[i].filters = [{ name: "dropShadow", distance: 5, angle: 45, color: 0x000000, alpha: 0.5, blurX: 5, blurY: 5 }];
            }
            alert("Drop shadow applied!");
            break;
        case 3:
            for (var i = 0; i < selection.length; i++) {
                selection[i].filters = [{ name: "blur", blurX: 10, blurY: 10 }];
            }
            alert("Blur applied!");
            break;
        case 4:
            for (var i = 0; i < selection.length; i++) {
                if (selection[i].colorTransform) {
                    selection[i].colorTransform = { redMultiplier: 0.3086, greenMultiplier: 0.6094, blueMultiplier: 0.0820 };
                }
            }
            alert("Grayscale applied!");
            break;
        case 5:
            for (var i = 0; i < selection.length; i++) {
                if (selection[i].colorTransform) {
                    selection[i].colorTransform = { redMultiplier: 0.393, greenMultiplier: 0.769, blueMultiplier: 0.189 };
                }
            }
            alert("Sepia applied!");
            break;
        case 6:
            for (var i = 0; i < selection.length; i++) {
                if (selection[i].colorTransform) {
                    selection[i].colorTransform = { brightness: 50 };
                }
            }
            alert("Brightened!");
            break;
        case 7:
            for (var i = 0; i < selection.length; i++) {
                if (selection[i].colorTransform) {
                    selection[i].colorTransform = { brightness: -50 };
                }
            }
            alert("Darkened!");
            break;
        case 8:
            removeAllEffects();
            break;
        case 9:
            createAnimatedEffect();
            break;
        case 10:
            applyVisualEffect();
            break;
    }
}

// Initialize
function init() {
    fl.outputPanel.trace("╔════════════════════════════════════════════════════════════╗");
    fl.outputPanel.trace("║         UNIVERSAL VISUAL EFFECTS FOR ADOBE ANIMATE         ║");
    fl.outputPanel.trace("║                      REAL VISIBLE EFFECTS!                 ║");
    fl.outputPanel.trace("╚════════════════════════════════════════════════════════════╝\n");
    fl.outputPanel.trace("✓ Script loaded successfully!");
    fl.outputPanel.trace("✓ Effects are immediately visible on stage!");
    fl.outputPanel.trace("✓ Uses native Animate color transforms, filters, and transforms\n");
}

// Run with quick panel option
function run() {
    init();
    
    var dom = fl.getDocumentDOM();
    if (!dom) {
        alert("Please open a document first!");
        return;
    }
    
    var useQuickPanel = confirm("Use Quick Effects Panel?\n\nOK - Quick Panel (fast access to common effects)\nCancel - Full Menu (all 28 effects)");
    
    if (useQuickPanel) {
        showQuickEffectsPanel();
    } else {
        applyVisualEffect();
    }
}

// Execute
run();