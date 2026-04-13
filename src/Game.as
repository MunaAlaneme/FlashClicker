package {
    import starling.display.Sprite;
    import starling.display.Quad;
    import starling.text.TextField;
    import starling.text.TextFormat;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
    import starling.events.Touch;
    import starling.events.EnterFrameEvent;
    import starling.display.*;
    import starling.core.*;
    import starling.animation.*;
    import starling.assets.*;
    import starling.text.*;
    import starling.geom.*;
    import utils.BigDouble;
    import starling.filters.*;
    import flash.geom.Point;
    import flash.utils.getTimer;
    import flash.media.*;
    import flash.events.Event;
    import flash.net.URLRequest;

    public class Game extends Sprite
    {

        private function tweenScale(obj:DisplayObject, scale:Number):void
        {
            var t:Tween = new Tween(obj, 0.1);
            t.scaleTo(scale);
            Starling.juggler.add(t);
        }
        private function tweenPos(obj:DisplayObject, x:Number, y:Number):void
        {
            var t:Tween = new Tween(obj, 0.1);
            t.moveTo(x, y);
            Starling.juggler.add(t);
        }

        private function get screenWidth():Number
        {
            return Starling.current.stage.stageWidth;
        }

        private function get screenHeight():Number
        {
            return Starling.current.stage.stageHeight;
        }
        private var mouseCircle2:Quad;
        private var targetX:Number = 0;
        private var targetY:Number = 0;
        private var upgradeInfo:Array = [
            {InitCost: new BigDouble(10,0), cost: new BigDouble(10,0), coefficient: new BigDouble(1.07,0), number: new BigDouble(0,0), name: "+1 Flash Per Second", multiplier: new BigDouble(1,0), lastMultiplier: new BigDouble(1,0)},
            {InitCost: new BigDouble(15,0), cost: new BigDouble(15,0), coefficient: new BigDouble(1.07,0), number: new BigDouble(0,0), name: "+1 Flash Per Click", multiplier: new BigDouble(1,0), lastMultiplier: new BigDouble(1,0)},
            {InitCost: new BigDouble(100,0), cost: new BigDouble(100,0), coefficient: new BigDouble(1.07,0), number: new BigDouble(0,0), name: "+5 FlPS", multiplier: new BigDouble(1,0), lastMultiplier: new BigDouble(1,0)},
            {InitCost: new BigDouble(150,0), cost: new BigDouble(150,0), coefficient: new BigDouble(1.07,0), number: new BigDouble(0,0), name: "+5 FlPC", multiplier: new BigDouble(1,0), lastMultiplier: new BigDouble(1,0)},
            {InitCost: new BigDouble(1000,0), cost: new BigDouble(1000,0), coefficient: new BigDouble(1.07,0), number: new BigDouble(0,0), name: "+25 FlPS", multiplier: new BigDouble(1,0), lastMultiplier: new BigDouble(1,0)},
            {InitCost: new BigDouble(1500,0), cost: new BigDouble(1500,0), coefficient: new BigDouble(1.07,0), number: new BigDouble(0,0), name: "+25 FlPC", multiplier: new BigDouble(1,0), lastMultiplier: new BigDouble(1,0)}
        ];
        private var upgradeMilestonesLevels:Array = [
            [10, 25, 50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1111, 1200, 1300, 1400, 1500, 1600, 1700, 1800, 1900, 2000, 2200, 2222, 2400, 2600, 2800, 3000, 3200, 3333, 3400, 3600, 3800, 4000, 4250, 4444, 4500, 4750, 5000, 5250, 5500, 5555, 5750, 6000, 6300, 6600, 6666, 6900, 7200, 7500, 7777, 7800, 8100, 8400, 8700, 8888, 9100, 9500, 9900, 9999, 10000],
            [10, 25, 50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1111, 1200, 1300, 1400, 1500, 1600, 1700, 1800, 1900, 2000, 2200, 2222, 2400, 2600, 2800, 3000, 3200, 3333, 3400, 3600, 3800, 4000, 4250, 4444, 4500, 4750, 5000, 5250, 5500, 5555, 5750, 6000, 6300, 6600, 6666, 6900, 7200, 7500, 7777, 7800, 8100, 8400, 8700, 8888, 9100, 9500, 9900, 9999, 10000],
            [10, 25, 50, 75, 100, 125, 150, 175, 200, 225, 250, 275, 300, 325, 333, 350, 375, 400, 425, 450, 475, 500, 525, 550, 575, 600, 625, 650, 675, 700, 750, 800, 850, 900, 950, 1000, 1100, 1111, 1200, 1300, 1400, 1500, 1600, 1700, 1800, 1900, 2000, 2200, 2400, 2600, 2800, 3000, 3200, 3400, 3600, 3800, 4000, 4250, 4500, 4750, 5000, 5300, 5600],
            [10, 25, 50, 75, 100, 125, 150, 175, 200, 225, 250, 275, 300, 325, 333, 350, 375, 400, 425, 450, 475, 500, 525, 550, 575, 600, 625, 650, 675, 700, 750, 800, 850, 900, 950, 1000, 1100, 1111, 1200, 1300, 1400, 1500, 1600, 1700, 1800, 1900, 2000, 2200, 2400, 2600, 2800, 3000, 3200, 3400, 3600, 3800, 4000, 4250, 4500, 4750, 5000, 5300, 5600],
            [10, 25, 50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1111, 1200, 1300, 1400, 1500, 1600, 1700, 1800, 1900, 2000, 2200, 2222, 2400, 2600, 2800, 3000, 3200, 3333, 3400, 3600, 3800, 4000, 4250, 4444, 4500, 4750, 5000, 5250, 5500, 5555, 5750, 6000, 6300, 6600, 6666, 6900, 7200, 7500, 7777, 7800, 8100, 8400, 8700, 8888, 9100, 9500, 9900, 9999, 10000],
            [10, 25, 50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1111, 1200, 1300, 1400, 1500, 1600, 1700, 1800, 1900, 2000, 2200, 2222, 2400, 2600, 2800, 3000, 3200, 3333, 3400, 3600, 3800, 4000, 4250, 4444, 4500, 4750, 5000, 5250, 5500, 5555, 5750, 6000, 6300, 6600, 6666, 6900, 7200, 7500, 7777, 7800, 8100, 8400, 8700, 8888, 9100, 9500, 9900, 9999, 10000]
        ];
        private var upgradeMilestonesMultipliers:Array = [
            [1.5, 2, 2, 2, 2, 2, 2, 4, 4, 4, 4, 4, 5, 4, 11, 4, 4, 4, 4, 4, 4, 4, 4, 5, 4, 4, 4, 4, 5, 4, 33, 4, 4, 4, 5, 5, 5, 5, 5, 10, 3, 3, 4, 4, 5, 3, 3, 66, 3, 3, 3, 77, 3, 9, 9, 9, 88, 20, 10, 5, 5, 5, 9999],
            [1.5, 2, 2, 2, 2, 2, 2, 4, 4, 4, 4, 4, 5, 4, 11, 4, 4, 4, 4, 4, 4, 4, 4, 5, 4, 4, 4, 4, 5, 4, 33, 4, 4, 4, 5, 5, 5, 5, 5, 10, 3, 3, 4, 4, 5, 3, 3, 66, 3, 3, 3, 77, 3, 9, 9, 9, 88, 20, 10, 5, 5, 5, 9999],
            [1.5, 2, 2, 2, 2, 2, 2, 3, 3, 4, 4, 4, 2.5, 2.5, 3.25, 3.5, 3.75, 4, 4.25, 4.5, 4.75, 5, 5, 5, 5, 5.5, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 9, 9, 9, 9, 10, 9999],
            [1.5, 2, 2, 2, 2, 2, 2, 3, 3, 4, 4, 4, 2.5, 2.5, 3.25, 3.5, 3.75, 4, 4.25, 4.5, 4.75, 5, 5, 5, 5, 5.5, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 9, 9, 9, 9, 10, 9999],
            [1.5, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 9999],
            [1.5, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 9999]
        ];

        private var note:String;
        private var noteMax:Number = 5;
        private var timeTotal:Number = 0;

        private var flashes:BigDouble = new BigDouble(20,0);
        private var toBuy:BigDouble = new BigDouble(1,0);
        private var toBuy2:Array = [];
        private var toBuyMax:Boolean = false;
        private var toBuyOCD:Boolean = false;
        private var flashesPerClick:BigDouble = new BigDouble(1,0);
        private var autoRate:BigDouble = new BigDouble(0,0); // flashes per second

        private var flashText:TextField;
        private var flpsText:TextField;
        private var flashButton:Canvas;
        private var upgradeButtons:Array = [];
        private var upgradeTexts:Array = [];

        private var ToBuyButton:Quad;
        private var ToBuyText:TextField;
        private var ToBuyMaxButton:Quad;
        private var ToBuyMaxText:TextField;
        private var ToBuyOCDButton:Quad;
        private var ToBuyOCDText:TextField;

        private var scrollContainer:Sprite;
        private var scrollMask:Quad;

        private var scrollX:Number = 0;
        private var maxScroll:Number = 0;

        private var scrollbar:Quad;
        private var isDraggingScroll:Boolean = false;

        private var musicStart:Sound;
        private var musicLoop:Sound;
        private var clickSound:Sound;
        private var upgradeSound:Sound;
        private var upgradeMilestoneSound:Sound;

        private var musicChannel:SoundChannel;
        private var soundsChannel:SoundChannel;

        private function createLightning(scale:Number):Canvas
        {
            var c:Canvas = new Canvas();
            c.beginFill(0xFFFF00); // yellow

            // Lightning bolt shape
            c.moveTo(0, 0);
            c.lineTo(20*scale, 0);
            c.lineTo(10*scale, 25*scale);
            c.lineTo(25*scale, 25*scale);
            c.lineTo(0, 60*scale);
            c.lineTo(8*scale, 35*scale);
            c.lineTo(-5*scale, 35*scale);

            c.endFill();

            return c;
        }

        public function randomInt(min:int = 0, max:int = int.MAX_VALUE):int
        {
            if (min == max) return min;
            if (min < max) return min + (Math.random() * (max - min + 1));
            else return max + (Math.random() * (min - max + 1));
        }
        public function randomDouble(min:Number = 0, max:Number = Number.MAX_VALUE):Number
        {
            if (min == max) return min;
            if (min < max) return min + (Math.random() * (max - min + 1));
            else return max + (Math.random() * (min - max + 1));
        }

        public function Game()
        {
            addEventListener(TouchEvent.TOUCH, onTouch);
            addEventListener(Event.ENTER_FRAME, onUpdate);
            createUI();
            var i:int = randomInt(1,3);
            if (i == 1) {
                musicStart = new Sound(new URLRequest("assets/audio/music/Peter Godfrey (Music for Media) - Hold on a Thereminute (Volume 5)-start.mp3"));
                musicLoop  = new Sound(new URLRequest("assets/audio/music/Peter Godfrey (Music for Media) - Hold on a Thereminute (Volume 5)-loop.mp3"));
            } else if (i == 2) {
                musicStart = new Sound(new URLRequest("assets/audio/music/Casino Park - Sonic Heroes [OST]-start.mp3"));
                musicLoop  = new Sound(new URLRequest("assets/audio/music/Casino Park - Sonic Heroes [OST]-loop.mp3"));
            } else if (i == 3) {
                musicStart = new Sound(new URLRequest("assets/audio/music/2024 OSHIN - November22nd12AM.mp3"));
                musicLoop  = new Sound(new URLRequest("assets/audio/music/2024 OSHIN - November22nd12AM.mp3"));
            }
            clickSound = new Sound(new URLRequest("assets/audio/sound/Sample_0002.mp3"));
            upgradeSound = new Sound(new URLRequest("assets/audio/sound/Sample_0018.mp3"));
            upgradeMilestoneSound = new Sound(new URLRequest("assets/audio/sound/cybershock sfx_upgrade.mp3"));
            playStartMusic();
        }
        private function playStartMusic():void
        {
            musicChannel = musicStart.play();
            musicChannel.addEventListener(Event.SOUND_COMPLETE, onStartMusicComplete);
        }
        private function onStartMusicComplete(e:Event):void
        {
            musicChannel.removeEventListener(Event.SOUND_COMPLETE, onStartMusicComplete);

            // loop forever (int.MAX_VALUE)
            musicChannel = musicLoop.play(0, int.MAX_VALUE);
        }
        private function onTouch(e:TouchEvent):void
        {
            var touch:Touch = e.getTouch(stage);

            if (touch)
            {
                var pos:Point = touch.getLocation(stage);
                targetX = pos.x;
                targetY = pos.y;

                // Click effect
                if (touch.phase == TouchPhase.BEGAN)
                {
                    soundsChannel = clickSound.play();
                    mouseCircle2.scaleX = mouseCircle2.scaleY = 1.6;
                }
            }
        }

        private function toPrecise(n:Number, decimals:int):String
        {
            var s:String = n.toFixed(decimals);

            // Remove trailing zeros
            s = s.replace(/\.?0+$/, "");

            return s;
        }

        private function formatDecimal(n:Number):String
        {
            return toPrecise(n, 3);
        }

        private function formatNumber(n:BigDouble):String
        {
            if (n.mantissa == 0) return "0";

            var exp:int = n.exponent;
            var man:Number = n.mantissa;

            // Small numbers (no suffix)
            if (exp < 3)
            {
                return formatDecimal(man * Math.pow(10, exp));
            }

            // Suffix list
            var suffixes:Array = [
                "", "K", "M", "B", "T",
                "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc", "UDc"
            ];

            var tier:int = Math.floor(exp / 3);

            var scaled:Number = man * Math.pow(10, exp % 3);

            // Handle overflow (e.g. 999.9 → 1.00K)
            if (scaled >= 1000)
            {
                scaled /= 1000;
                tier++;
            }

            // Dynamic precision
            var decimals:int = 3;

            var formatted:String = toPrecise(scaled, decimals);

            if (tier < suffixes.length)
            {
                return formatted + suffixes[tier];
            }

            // Scientific fallback
            return toPrecise(man, 3) + "e" + exp;
        }
        private function createUI():void
        {
            for (var i:int = 0; i < 6; i++) {
                upgradeTexts.push(new TextField(300, 100, "", new TextFormat("Verdana", 20, 0xFFFFFF)));
                upgradeButtons.push(new Quad(300*(screenWidth/1280), 100*(screenHeight/720), 0x4444AA));
            }
            // Score
            flashText = new TextField(1280, 40, "", new TextFormat("Verdana", 32, 0xFFFFFF));
            flashText.y = 20;
            addChild(flashText);

            flpsText = new TextField(1280, 100, "", new TextFormat("Verdana", 20, 0xAAAAAA));
            flpsText.y = 45;
            addChild(flpsText);
//button.x = screenWidth * 0.5;
//button.y = screenHeight * 0.8;
            // Flash button
            flashButton = createLightning(4);
            flashButton.x = 640;
            flashButton.y = 200;
            flashButton.width = 120;
            flashButton.height = 240;
            flashButton.addEventListener(TouchEvent.TOUCH, onFlashClick);
            flashButton.addEventListener(TouchEvent.TOUCH, onButtonTouch);
            addChild(flashButton);

            // To Buy Button
            ToBuyButton = new Quad(100*(screenWidth/1280), 50*(screenHeight/720), 0x4444AA);
            ToBuyButton.x = 400*(screenWidth/1280);
            ToBuyButton.y = 150*(screenHeight/720);
            ToBuyButton.addEventListener(TouchEvent.TOUCH, onUpgrade);
            addChild(ToBuyButton);
            ToBuyButton.addEventListener(TouchEvent.TOUCH, onButtonTouch);

            ToBuyMaxButton = new Quad(150*(screenWidth/1280), 50*(screenHeight/720), 0x4444AA);
            ToBuyMaxButton.x = 350*(screenWidth/1280);
            ToBuyMaxButton.y = 225*(screenHeight/720);
            ToBuyMaxButton.addEventListener(TouchEvent.TOUCH, onUpgrade);
            addChild(ToBuyMaxButton);
            ToBuyMaxButton.addEventListener(TouchEvent.TOUCH, onButtonTouch);

            ToBuyOCDButton = new Quad(150*(screenWidth/1280), 50*(screenHeight/720), 0x4444AA);
            ToBuyOCDButton.x = 350*(screenWidth/1280);
            ToBuyOCDButton.y = 300*(screenHeight/720);
            ToBuyOCDButton.addEventListener(TouchEvent.TOUCH, onUpgrade);
            addChild(ToBuyOCDButton);
            ToBuyOCDButton.addEventListener(TouchEvent.TOUCH, onButtonTouch);

            ToBuyText = new TextField(100, 50, "", new TextFormat("Verdana", 20, 0xFFFFFF));
            ToBuyText.x = 400*(screenWidth/1280);
            ToBuyText.y = 150*(screenHeight/720);
            ToBuyText.touchable = false;
            addChild(ToBuyText);

            ToBuyMaxText = new TextField(150, 50, "", new TextFormat("Verdana", 20, 0xFFFFFF));
            ToBuyMaxText.x = 350*(screenWidth/1280);
            ToBuyMaxText.y = 225*(screenHeight/720);
            ToBuyMaxText.touchable = false;
            addChild(ToBuyMaxText);

            ToBuyOCDText = new TextField(150, 50, "", new TextFormat("Verdana", 20, 0xFFFFFF));
            ToBuyOCDText.x = 350*(screenWidth/1280);
            ToBuyOCDText.y = 300*(screenHeight/720);
            ToBuyOCDText.touchable = false;
            addChild(ToBuyOCDText);

            scrollContainer = new Sprite();
            addChild(scrollContainer);

            // Mask (visible area)
            scrollMask = new Quad(1000, 200, 0x000000);
            scrollMask.alpha = 0.0; // invisible but still masks
            scrollMask.x = 20;
            scrollMask.y = 200;

            addChild(scrollMask);

            scrollContainer.x = scrollMask.x;
            scrollContainer.y = scrollMask.y;

            scrollContainer.mask = scrollMask;

            // Upgrade button
            i = -1;
            while (++i < 6) {
                upgradeButtons[i].x = 60 + i*320 - scrollX;
                upgradeButtons[i].y = 480;
                upgradeButtons[i].addEventListener(TouchEvent.TOUCH, onUpgrade);

                upgradeTexts[i].x = 60 + i*320 - scrollX;
                upgradeTexts[i].y = 480;
                upgradeTexts[i].touchable = false;
            }


            for (i = 0; i < 6; i++) {
                addChild(upgradeButtons[i]);
                addChild(upgradeTexts[i]);
                upgradeButtons[i].addEventListener(TouchEvent.TOUCH, onButtonTouch);
                toBuy2.push(new BigDouble(1,0));
            }
            maxScroll = Math.max(0, scrollContainer.width - scrollMask.width);
            scrollMask.addEventListener(TouchEvent.TOUCH, onScrollTouch);

            scrollbar = new Quad(50, 6, 0xAAAAAA);
            scrollbar.y = scrollMask.y + scrollMask.height + 5;
            scrollbar.x = scrollMask.x;

            addChild(scrollbar);

            scrollbar.addEventListener(TouchEvent.TOUCH, onScrollbarDrag);
            addEventListener("mouseWheel", onMouseWheel);

            mouseCircle2 = new Quad(20, 20, 0xFFFFAA);
            mouseCircle2.pivotX = 10;
            mouseCircle2.pivotY = 10;
            mouseCircle2.alpha = 0.6;
            mouseCircle2.touchable = false;

            addChild(mouseCircle2);

            updateUI();
        }

        private function onScrollTouch(e:TouchEvent):void
        {
            var touch:Touch = e.getTouch(scrollMask);

            if (!touch) return;

            if (touch.phase == TouchPhase.MOVED)
            {
                var delta:Number = touch.getMovement(scrollMask).x;

                scrollX -= delta;
                clampScroll();
            }
        }
        private function clampScroll():void
        {
            if (scrollX < 0) scrollX = 0;
            if (scrollX > maxScroll) scrollX = maxScroll;

            scrollContainer.x = scrollMask.x - scrollX;

            updateScrollbar();
        }

        private function updateScrollbar():void
        {
            if (maxScroll <= 0)
            {
                scrollbar.visible = false;
                return;
            }

            scrollbar.visible = true;

            var ratio:Number = scrollX / maxScroll;

            scrollbar.x = scrollMask.x + ratio * (scrollMask.width - scrollbar.width);
        }

        private function onScrollbarDrag(e:TouchEvent):void
        {
            var touch:Touch = e.getTouch(scrollbar);

            if (!touch) return;

            if (touch.phase == TouchPhase.MOVED)
            {
                var localX:Number = touch.getLocation(this).x - 25;

                var minX:Number = scrollMask.x;
                var maxX:Number = scrollMask.x + scrollMask.width - scrollbar.width;

                scrollbar.x = Math.max(minX, Math.min(maxX, localX));

                var ratio:Number = (scrollbar.x - minX) / (maxX - minX);

                scrollX = ratio * maxScroll;

                 scrollContainer.x += ((scrollMask.x - scrollX) - scrollContainer.x) * 0.2;
            }
        }
        private function onMouseWheel(e:*):void
        {
            scrollX -= e.delta * 20;
            clampScroll();
        }

        private function onUpdate(e:EnterFrameEvent):void
        {
            // Smooth follow (lag)
            mouseCircle2.x += (targetX - mouseCircle2.x) * 0.15;
            mouseCircle2.y += (targetY - mouseCircle2.y) * 0.15;

            // Smooth scale back
            mouseCircle2.scaleX += (1 - mouseCircle2.scaleX) * 0.2;
            mouseCircle2.scaleY = mouseCircle2.scaleX;

            // Subtle pulse
            mouseCircle2.scaleX += Math.sin(getTimer() * 0.005) * 0.01;
            mouseCircle2.scaleY = mouseCircle2.scaleX;

            // Fade based on movement
            var dx:Number = targetX - mouseCircle2.x;
            var dy:Number = targetY - mouseCircle2.y;
            var dist:Number = Math.sqrt(dx * dx + dy * dy);

            mouseCircle2.alpha = Math.min(1, dist / 40 + 0.2);
            var dt:Number = e.passedTime; // seconds since last frame
            timeTotal+=dt;

            // Auto flashes
            flashes = flashes.add(autoRate.multiply(new BigDouble(dt, 0)));

            updateUI();
        }
        private function onButtonTouch(e:TouchEvent):void
        {
            var btn:DisplayObject = e.currentTarget as DisplayObject;

            var touch:Touch = e.getTouch(btn);
            var filter:ColorMatrixFilter = new ColorMatrixFilter();
            var x:Number = btn.x;
            var y:Number = btn.y;
            if (btn == flashButton) {
                x = 640;
                y = 200;
            }
            var i:int = -1;
            while (++i < 6) {
                if (btn == upgradeButtons[i]) {
                    x = (60 + 320*i) - scrollX;
                    y = 480;
                }
            }
            if (btn == ToBuyButton) {
                x = 400;
                y = 150;
            }
            if (btn == ToBuyMaxButton || btn == ToBuyOCDButton) {
                x = 350;
            }
            if (btn == ToBuyMaxButton) {
                y = 225;
            }
            if (btn == ToBuyOCDButton) {
                y = 300;
            }

            if (!touch)
            {
                // Mouse left button
                btn.alpha = 1.0;
                tweenScale(btn, 1.0)
                tweenPos(btn, x, y)
                btn.filter = null;
                return;
            }

            if (touch.phase == TouchPhase.HOVER)
            {
                // Hover effect
                btn.alpha = 0.8;
                tweenScale(btn, 1.05)
                tweenPos(btn, (x - (btn.width*0.025)), y - (btn.height*0.025))
                btn.filter = new GlowFilter(0xFFFFFF, 0.5, 8, 8);
            }
            else if (touch.phase == TouchPhase.BEGAN)
            {
                // Click press
                tweenScale(btn, 0.95)
                tweenPos(btn, (x + (btn.width*0.025)), y + (btn.height*0.025))
                filter.tint(0xFFFFAA, 0.5);

                btn.filter = filter;
            }
            else if (touch.phase == TouchPhase.ENDED)
            {
                // Release
                tweenPos(btn, (x - (btn.width*0.025)), y - (btn.height*0.025))
                tweenScale(btn, 1.05)
            }
        }

        private function onFlashClick(e:TouchEvent):void
        {
            var touch:Touch = e.getTouch(flashButton, TouchPhase.BEGAN);
            if (touch)
            {
                flashes = flashes.add(flashesPerClick);
                updateUI();
            }
        }

        private function onUpgrade(e:TouchEvent):void
        {
            if (e.getTouch(ToBuyButton, TouchPhase.BEGAN))
            {
                soundsChannel = upgradeSound.play();
                if (toBuy.equals(new BigDouble(1,0))) {
                    toBuy = new BigDouble(5,0);
                } else if (toBuy.equals(new BigDouble(5,0))) {
                    toBuy = new BigDouble(10,0);
                } else if (toBuy.equals(new BigDouble(10,0))) {
                    toBuy = new BigDouble(25,0);
                } else if (toBuy.equals(new BigDouble(25,0))) {
                    toBuy = new BigDouble(50,0);
                } else if (toBuy.equals(new BigDouble(50,0))) {
                    toBuy = new BigDouble(100,0);
                } else if (toBuy.equals(new BigDouble(100,0))) {
                    toBuy = new BigDouble(500,0);
                } else if (toBuy.equals(new BigDouble(500,0))) {
                    toBuy = new BigDouble(1000,0);
                } else if (toBuy.equals(new BigDouble(1000,0))) {
                    toBuy = new BigDouble(1,0);
                }
                updateUI();
            }
            if (e.getTouch(ToBuyMaxButton, TouchPhase.BEGAN))
            {
                soundsChannel = upgradeSound.play();
                toBuyMax = !toBuyMax;
                updateUI();
            }
            if (e.getTouch(ToBuyOCDButton, TouchPhase.BEGAN))
            {
                soundsChannel = upgradeSound.play();
                toBuyOCD = !toBuyOCD;
                updateUI();
            }
            for (var i:int = 0; i < 6; i++) {
                if (e.getTouch(upgradeButtons[i], TouchPhase.BEGAN) && (flashes.greaterOrEqual(upgradeInfo[i].cost)))
                {
                    soundsChannel = upgradeSound.play();
                    flashes = flashes.subtract(upgradeInfo[i].cost);
                    upgradeInfo[i].number = upgradeInfo[i].number.add(toBuy2[i]);
                    // Scale cost (important for clicker games)
                    updateUI();
                }
                if (!upgradeInfo[i].lastMultiplier.equals(upgradeInfo[i].multiplier)) {
                    soundsChannel = upgradeMilestoneSound.play();
                }
                upgradeInfo[i].lastMultiplier = upgradeInfo[i].multiplier
                upgradeInfo[i].multiplier = new BigDouble(1,0);
                for (var j:int = 0; j < upgradeMilestonesLevels[i].length; j++) {
                    upgradeMilestonesLevels[i][j] = BigDouble.fromNumber(upgradeMilestonesLevels[i][j]);
                    if (upgradeInfo[i].number.greaterOrEqual(upgradeMilestonesLevels[i][j])) {
                        upgradeMilestonesMultipliers[i][j] =  BigDouble.fromNumber(upgradeMilestonesMultipliers[i][j]);
                        upgradeInfo[i].multiplier = upgradeInfo[i].multiplier.multiply(upgradeMilestonesMultipliers[i][j]);
                    }
                }
            }
            
        }

        private function updateUI():void
        {
            if ((Math.floor(timeTotal/10))%noteMax == 0) {
                note = "Welcome to Flash Clicker.";
            } else if ((Math.floor(timeTotal/10))%noteMax == 1) {
                note = "If an item is stuck at 115 generators, just turn off OCD until the item is ready.";
            } else if ((Math.floor(timeTotal/10))%noteMax == 2) {
                note = "null";
            } else if ((Math.floor(timeTotal/10))%noteMax == 3) {
                note = timeTotal.toFixed(3);
            } else if ((Math.floor(timeTotal/10))%noteMax == 4) {
                note = "I ran out of ideas";
            }
            autoRate = (upgradeInfo[0].number.multiply(upgradeInfo[0].multiplier)).add(
                upgradeInfo[2].number.multiply(upgradeInfo[2].multiplier).multiply(new BigDouble(5,0))
            ).add(
                upgradeInfo[4].number.multiply(upgradeInfo[4].multiplier).multiply(new BigDouble(25,0))
            );
            flashesPerClick = (upgradeInfo[1].number.multiply(upgradeInfo[1].multiplier)).add(
                upgradeInfo[3].number.multiply(upgradeInfo[3].multiplier).multiply(new BigDouble(5,0))
            ).add(
                upgradeInfo[5].number.multiply(upgradeInfo[5].multiplier).multiply(new BigDouble(25,0))
            );
            flashText.text = "Flashes: " + formatNumber(flashes);
            flpsText.text = "Per second: " + formatNumber(autoRate) + "\nPer click: " + formatNumber(flashesPerClick) + "\n" + note;
            var i00001:int = -1;
            while (++i00001 < upgradeInfo.length) {
                toBuy2[i00001] = toBuy;
                if (toBuyMax) {
                    toBuy2[i00001] = (
                        (((flashes.multiply(upgradeInfo[i00001].coefficient.subtract(new BigDouble(1,0)))).divide(upgradeInfo[i00001].InitCost.multiply(upgradeInfo[i00001].coefficient.pow(upgradeInfo[i00001].number))).add(new BigDouble(1,0))).log10Big()).divide(upgradeInfo[i00001].coefficient.log10Big())
                    ).divide(toBuy).floor().multiply(toBuy);
                    if (toBuy2[i00001].lessThan(toBuy)) {
                        toBuy2[i00001] = toBuy;
                    }
                }
                if (toBuyOCD) {
                    toBuy2[i00001] = toBuy2[i00001].subtract(upgradeInfo[i00001].number.mod(toBuy));
                }
                upgradeInfo[i00001].cost = upgradeInfo[i00001].InitCost.multiply( upgradeInfo[i00001].coefficient.pow(upgradeInfo[i00001].number).multiply(upgradeInfo[i00001].coefficient.pow(toBuy2[i00001]).subtract(new BigDouble(1,0))).divide(upgradeInfo[i00001].coefficient.subtract(new BigDouble(1,0))));
                upgradeTexts[i00001].text = upgradeInfo[i00001].name + "\nCost: " + formatNumber(upgradeInfo[i00001].cost) + "\n" + formatNumber(upgradeInfo[i00001].number) + " (+" + formatNumber(toBuy2[i00001]) + ")";
                if (flashes.lessThan(upgradeInfo[i00001].cost)) {
                    upgradeButtons[i00001].alpha = 0.5;
                } else {upgradeButtons[i00001].alpha = 1.0;}
                upgradeTexts[i00001].scale = upgradeButtons[i00001].scale;
                upgradeTexts[i00001].x = upgradeButtons[i00001].x;
                upgradeTexts[i00001].y = upgradeButtons[i00001].y;
            }

            ToBuyText.scale = ToBuyButton.scale;
            ToBuyText.x = ToBuyButton.x;
            ToBuyText.y = ToBuyButton.y;
            ToBuyText.text = "x" + int(toBuy);
            ToBuyMaxText.scale = ToBuyMaxButton.scale;
            ToBuyMaxText.x = ToBuyMaxButton.x;
            ToBuyMaxText.y = ToBuyMaxButton.y;
            ToBuyMaxText.text = "Max: " + toBuyMax;
            ToBuyOCDText.scale = ToBuyOCDButton.scale;
            ToBuyOCDText.x = ToBuyOCDButton.x;
            ToBuyOCDText.y = ToBuyOCDButton.y;
            ToBuyOCDText.text = "OCD: " + toBuyOCD;
        }
    }
}