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
    import starling.animation.Tween;
    import starling.filters.*;
    import starling.display.Image;
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

        private var cookies:BigDouble = new BigDouble(0,0);
        private var generators:BigDouble = new BigDouble(0,0);
        private var deltaTime:BigDouble = new BigDouble(0,0);
        private var cookiesPerClick:BigDouble = new BigDouble(1,0);
        private var autoRate:BigDouble = new BigDouble(0,0); // cookies per second
        private var upgradeCost:BigDouble = new BigDouble(10,0);
        private var upgradeCost2:BigDouble = new BigDouble(15,0);
        private var upgradeCost3:BigDouble = new BigDouble(100,0);

        private var cookieText:TextField;
        private var cpsText:TextField;
        private var cookieButton:Quad;
        private var upgradeButton:Quad;
        private var upgradeText:TextField;
        private var upgradeButton2:Quad;
        private var upgradeText2:TextField;
        private var upgradeButton3:Quad;
        private var upgradeText3:TextField;

        private var musicStart:Sound;
        private var musicLoop:Sound;

        private var musicChannel:SoundChannel;

        public function Game()
        {
            addEventListener(EnterFrameEvent.ENTER_FRAME, onUpdate);
            Starling.current.stage.addEventListener(TouchEvent.TOUCH, onTouch);
            addEventListener(Event.ENTER_FRAME, onUpdate);
            createUI();
            musicStart = new Sound(new URLRequest("assets/audio/music/Peter Godfrey (Music for Media) - Hold on a Thereminute (Volume 5)-start.mp3"));
            musicLoop  = new Sound(new URLRequest("assets/audio/music/Peter Godfrey (Music for Media) - Hold on a Thereminute (Volume 5)-loop.mp3"));

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
                "Qa", "Qi", "Sx", "Sp", "Oc", "No"
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
            // Score
            cookieText = new TextField(1280, 60, "", new TextFormat("Verdana", 32, 0xFFFFFF));
            cookieText.y = 20;
            addChild(cookieText);

            cpsText = new TextField(1280, 70, "", new TextFormat("Verdana", 20, 0xAAAAAA));
            cpsText.y = 70;
            addChild(cpsText);
//button.x = screenWidth * 0.5;
//button.y = screenHeight * 0.8;
            // Cookie button
            cookieButton = new Quad(250*(screenWidth/1280), 250*(screenHeight/720), 0xCC9900);
            cookieButton.x = 515*(screenWidth/1280);
            cookieButton.y = 200*(screenHeight/720);
            cookieButton.addEventListener(TouchEvent.TOUCH, onCookieClick);
            addChild(cookieButton);

            // Upgrade button
            upgradeButton = new Quad(300*(screenWidth/1280), 100*(screenHeight/720), 0x4444AA);
            upgradeButton.x = 140*(screenWidth/1280);
            upgradeButton.y = 500*(screenHeight/720);
            upgradeButton.addEventListener(TouchEvent.TOUCH, onUpgrade);
            addChild(upgradeButton);

            upgradeText = new TextField(300, 100, "", new TextFormat("Verdana", 20, 0xFFFFFF));
            upgradeText.x = 140*(screenWidth/1280);
            upgradeText.y = 500*(screenHeight/720);
            upgradeText.touchable = false;
            addChild(upgradeText);

            upgradeButton2 = new Quad(300*(screenWidth/1280), 100*(screenHeight/720), 0x4444AA);
            upgradeButton2.x = 490*(screenWidth/1280);
            upgradeButton2.y = 500*(screenHeight/720);
            upgradeButton2.addEventListener(TouchEvent.TOUCH, onUpgrade2);
            addChild(upgradeButton2);

            upgradeText2 = new TextField(300, 100, "", new TextFormat("Verdana", 20, 0xFFFFFF));
            upgradeText2.x = 490*(screenWidth/1280);
            upgradeText2.y = 500*(screenHeight/720);
            upgradeText2.touchable = false;
            addChild(upgradeText2);

            upgradeButton3 = new Quad(300*(screenWidth/1280), 100*(screenHeight/720), 0x4444AA);
            upgradeButton3.x = 840*(screenWidth/1280);
            upgradeButton3.y = 500*(screenHeight/720);
            upgradeButton3.addEventListener(TouchEvent.TOUCH, onUpgrade3);
            addChild(upgradeButton3);

            upgradeText3 = new TextField(300, 100, "", new TextFormat("Verdana", 20, 0xFFFFFF));
            upgradeText3.x = 840*(screenWidth/1280);
            upgradeText3.y = 500*(screenHeight/720);
            upgradeText3.touchable = false;
            addChild(upgradeText3);

            mouseCircle2 = new Quad(20, 20, 0xFFFFAA);
            mouseCircle2.pivotX = 10;
            mouseCircle2.pivotY = 10;
            mouseCircle2.alpha = 0.6;
            mouseCircle2.touchable = false;

            addChild(mouseCircle2);

            updateUI();
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

            // Auto cookies
            cookies = cookies.add(autoRate.multiply(new BigDouble(dt, 0)));

            updateUI();
        }
        private function onButtonTouch(e:TouchEvent):void
        {
            var btn:DisplayObject = e.currentTarget as DisplayObject;

            var touch:Touch = e.getTouch(btn);
            var filter:ColorMatrixFilter = new ColorMatrixFilter();

            if (!touch)
            {
                // Mouse left button
                btn.alpha = 1.0;
                tweenScale(btn, 1.0)
                btn.filter = null;
                Image(btn).color = 0xFFFFFF;
                return;
            }

            if (touch.phase == TouchPhase.HOVER)
            {
                // Hover effect
                btn.alpha = 0.8;
                tweenScale(btn, 1.05)
                btn.filter = new GlowFilter(0xFFFFFF, 0.5, 8, 8);
            }
            else if (touch.phase == TouchPhase.BEGAN)
            {
                // Click press
                tweenScale(btn, 0.95)
                filter.tint(0xFFFFAA, 0.3);

                btn.filter = filter;
            }
            else if (touch.phase == TouchPhase.ENDED)
            {
                // Release
                tweenScale(btn, 1.05)
            }
        }

        private function onCookieClick(e:TouchEvent):void
        {
            var touch:Touch = e.getTouch(cookieButton, TouchPhase.BEGAN);
            if (touch)
            {
                cookies = cookies.add(cookiesPerClick);
                updateUI();
            }
        }

        private function onUpgrade(e:TouchEvent):void
        {
            var touch:Touch = e.getTouch(upgradeButton, TouchPhase.BEGAN);
            if (touch && (cookies.greaterOrEqual(upgradeCost)))
            {
                cookies = cookies.subtract(upgradeCost);

                // Increase production
                autoRate = autoRate.add(new BigDouble(1,0));

                // Scale cost (important for clicker games)
                upgradeCost = upgradeCost.multiply(new BigDouble(1.1, 0));

                updateUI();
            }
        }
        private function onUpgrade2(e:TouchEvent):void
        {
            var touch:Touch = e.getTouch(upgradeButton2, TouchPhase.BEGAN);
            if (touch && (cookies.greaterOrEqual(upgradeCost2)))
            {
                cookies = cookies.subtract(upgradeCost2);

                // Increase production
                cookiesPerClick = cookiesPerClick.add(new BigDouble(1,0));

                // Scale cost (important for clicker games)
                upgradeCost2 = upgradeCost2.multiply(new BigDouble(1.1, 0));

                updateUI();
            }
        }
        private function onUpgrade3(e:TouchEvent):void
        {
            var touch:Touch = e.getTouch(upgradeButton3, TouchPhase.BEGAN);
            if (touch && (cookies.greaterOrEqual(upgradeCost3)))
            {
                cookies = cookies.subtract(upgradeCost3);

                // Increase production
                autoRate = autoRate.add(new BigDouble(5,0));

                // Scale cost (important for clicker games)
                upgradeCost3 = upgradeCost3.multiply(new BigDouble(1.1, 0));

                updateUI();
            }
        }

        private function updateUI():void
        {
            cookieText.text = "Cookies: " + formatNumber(cookies);
            cpsText.text = "Per second: " + formatNumber(autoRate) + "\nPer click: " + formatNumber(cookiesPerClick);

            upgradeText.text = "+1 Cookie Per Second\nCost: " + formatNumber(upgradeCost);
            upgradeText2.text = "+1 Cookie Per Click\nCost: " + formatNumber(upgradeCost2);
            upgradeText3.text = "+5 CPS\nCost: " + formatNumber(upgradeCost3);
            if (cookies.lessThan(upgradeCost)) {
                upgradeButton.alpha = 0.5;
            } else {upgradeButton.alpha = 1.0;}
            if (cookies.lessThan(upgradeCost2)) {
                upgradeButton2.alpha = 0.5;
            } else {upgradeButton2.alpha = 1.0;}
            if (cookies.lessThan(upgradeCost3)) {
                upgradeButton3.alpha = 0.5;
            } else {upgradeButton3.alpha = 1.0;}
        }
    }
}