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
        private var upgradeInfo:Array = [
            {InitCost: new BigDouble(10,0), cost: new BigDouble(10,0), coefficient: new BigDouble(1.07,0), number: new BigDouble(0,0), name: "+1 Cookie Per Second"},
            {InitCost: new BigDouble(15,0), cost: new BigDouble(15,0), coefficient: new BigDouble(1.07,0), number: new BigDouble(0,0), name: "+1 Cookie Per Click"},
            {InitCost: new BigDouble(100,0), cost: new BigDouble(100,0), coefficient: new BigDouble(1.07,0), number: new BigDouble(0,0), name: "+5 CPS"},
            {InitCost: new BigDouble(150,0), cost: new BigDouble(150,0), coefficient: new BigDouble(1.07,0), number: new BigDouble(0,0), name: "+5 CPC"}
        ];

        private var cookies:BigDouble = new BigDouble(20,0);
        private var toBuy:BigDouble = new BigDouble(1,0);
        private var deltaTime:BigDouble = new BigDouble(0,0);
        private var cookiesPerClick:BigDouble = new BigDouble(1,0);
        private var autoRate:BigDouble = new BigDouble(0,0); // cookies per second

        private var cookieText:TextField;
        private var cpsText:TextField;
        private var cookieButton:Quad;
        private var upgradeButton:Quad;
        private var upgradeText:TextField;
        private var upgradeButton2:Quad;
        private var upgradeText2:TextField;
        private var upgradeButton3:Quad;
        private var upgradeText3:TextField;
        private var upgradeButton4:Quad;
        private var upgradeText4:TextField;

        private var ToBuyButton:Quad;
        private var ToBuyText:TextField;

        private var musicStart:Sound;
        private var musicLoop:Sound;
        private var clickSound:Sound;
        private var upgradeSound:Sound;

        private var musicChannel:SoundChannel;
        private var soundsChannel:SoundChannel;

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

            // To Buy Button
            ToBuyButton = new Quad(100*(screenWidth/1280), 50*(screenHeight/720), 0x4444AA);
            ToBuyButton.x = 400*(screenWidth/1280);
            ToBuyButton.y = 150*(screenHeight/720);
            ToBuyButton.addEventListener(TouchEvent.TOUCH, onUpgrade);
            addChild(ToBuyButton);

            ToBuyText = new TextField(100, 50, "", new TextFormat("Verdana", 20, 0xFFFFFF));
            ToBuyText.x = 400*(screenWidth/1280);
            ToBuyText.y = 150*(screenHeight/720);
            ToBuyText.touchable = false;
            addChild(ToBuyText);

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
            upgradeButton2.addEventListener(TouchEvent.TOUCH, onUpgrade);
            addChild(upgradeButton2);

            upgradeText2 = new TextField(300, 100, "", new TextFormat("Verdana", 20, 0xFFFFFF));
            upgradeText2.x = 490*(screenWidth/1280);
            upgradeText2.y = 500*(screenHeight/720);
            upgradeText2.touchable = false;
            addChild(upgradeText2);

            upgradeButton3 = new Quad(300*(screenWidth/1280), 100*(screenHeight/720), 0x4444AA);
            upgradeButton3.x = 840*(screenWidth/1280);
            upgradeButton3.y = 500*(screenHeight/720);
            upgradeButton3.addEventListener(TouchEvent.TOUCH, onUpgrade);
            addChild(upgradeButton3);

            upgradeText3 = new TextField(300, 100, "", new TextFormat("Verdana", 20, 0xFFFFFF));
            upgradeText3.x = 840*(screenWidth/1280);
            upgradeText3.y = 500*(screenHeight/720);
            upgradeText3.touchable = false;
            addChild(upgradeText3);
            
            upgradeButton4 = new Quad(300*(screenWidth/1280), 100*(screenHeight/720), 0x4444AA);
            upgradeButton4.x = 490*(screenWidth/1280);
            upgradeButton4.y = 600*(screenHeight/720);
            upgradeButton4.addEventListener(TouchEvent.TOUCH, onUpgrade);
            addChild(upgradeButton4);

            upgradeText4 = new TextField(300, 100, "", new TextFormat("Verdana", 20, 0xFFFFFF));
            upgradeText4.x = 490*(screenWidth/1280);
            upgradeText4.y = 600*(screenHeight/720);
            upgradeText4.touchable = false;
            addChild(upgradeText4);

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
            if (e.getTouch(upgradeButton, TouchPhase.BEGAN) && (cookies.greaterOrEqual(upgradeInfo[0].cost)))
            {
                soundsChannel = upgradeSound.play();
                cookies = cookies.subtract(upgradeInfo[0].cost);
                // Scale cost (important for clicker games)
                upgradeInfo[0].number = upgradeInfo[0].number.add(toBuy);
                updateUI();
            }
            if (e.getTouch(upgradeButton2, TouchPhase.BEGAN) && (cookies.greaterOrEqual(upgradeInfo[1].cost)))
            {
                soundsChannel = upgradeSound.play();
                cookies = cookies.subtract(upgradeInfo[1].cost);
                // Scale cost (important for clicker games)
                upgradeInfo[1].number = upgradeInfo[1].number.add(toBuy);
                updateUI();
            }
            if (e.getTouch(upgradeButton3, TouchPhase.BEGAN) && (cookies.greaterOrEqual(upgradeInfo[2].cost)))
            {
                soundsChannel = upgradeSound.play();
                cookies = cookies.subtract(upgradeInfo[2].cost);
                // Scale cost (important for clicker games)
                upgradeInfo[2].number = upgradeInfo[2].number.add(toBuy);
                updateUI();
            }
            if (e.getTouch(upgradeButton4, TouchPhase.BEGAN) && (cookies.greaterOrEqual(upgradeInfo[3].cost)))
            {
                soundsChannel = upgradeSound.play();
                cookies = cookies.subtract(upgradeInfo[3].cost);
                // Scale cost (important for clicker games)
                upgradeInfo[3].number = upgradeInfo[3].number.add(toBuy);
                updateUI();
            }
        }

        private function updateUI():void
        {
            autoRate = upgradeInfo[0].number.add(upgradeInfo[2].number.multiply(new BigDouble(5,0)));
            cookiesPerClick = upgradeInfo[1].number.add(upgradeInfo[3].number.multiply(new BigDouble(5,0)));
            cookieText.text = "Cookies: " + formatNumber(cookies);
            cpsText.text = "Per second: " + formatNumber(autoRate) + "\nPer click: " + formatNumber(cookiesPerClick);
            var i00001:int = -1;
            while (++i00001 < upgradeInfo.length) {
                upgradeInfo[i00001].cost = upgradeInfo[i00001].InitCost.multiply( upgradeInfo[i00001].coefficient.pow(upgradeInfo[i00001].number).multiply(upgradeInfo[i00001].coefficient.pow(toBuy).subtract(new BigDouble(1,0))).divide(upgradeInfo[i00001].coefficient.subtract(new BigDouble(1,0))));
            }

            ToBuyText.text = "x" + int(toBuy);

            upgradeText.text = upgradeInfo[0].name + "\nCost: " + formatNumber(upgradeInfo[0].cost) + "\n" + formatNumber(upgradeInfo[0].number);
            upgradeText2.text = upgradeInfo[1].name + "\nCost: " + formatNumber(upgradeInfo[1].cost) + "\n" + formatNumber(upgradeInfo[1].number);
            upgradeText3.text = upgradeInfo[2].name + "\nCost: " + formatNumber(upgradeInfo[2].cost) + "\n" + formatNumber(upgradeInfo[2].number);
            upgradeText4.text = upgradeInfo[3].name + "\nCost: " + formatNumber(upgradeInfo[3].cost) + "\n" + formatNumber(upgradeInfo[3].number);
            if (cookies.lessThan(upgradeInfo[0].cost)) {
                upgradeButton.alpha = 0.5;
            } else {upgradeButton.alpha = 1.0;}
            if (cookies.lessThan(upgradeInfo[1].cost)) {
                upgradeButton2.alpha = 0.5;
            } else {upgradeButton2.alpha = 1.0;}
            if (cookies.lessThan(upgradeInfo[2].cost)) {
                upgradeButton3.alpha = 0.5;
            } else {upgradeButton3.alpha = 1.0;}
            if (cookies.lessThan(upgradeInfo[3].cost)) {
                upgradeButton4.alpha = 0.5;
            } else {upgradeButton4.alpha = 1.0;}
        }
    }
}