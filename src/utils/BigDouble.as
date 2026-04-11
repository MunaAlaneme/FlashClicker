package utils
{
    public class BigDouble
    {
        public var mantissa:Number;
        public var exponent:Number;

        public function BigDouble(m:Number = 0, e:Number = 0)
        {
            mantissa = m;
            exponent = e;
            normalize();
        }

        // 🔧 Normalize to 1 ≤ mantissa < 10
        public function normalize():void
        {
            if (mantissa == 0)
            {
                exponent = 0;
                return;
            }

            var log10:Number = Math.log(Math.abs(mantissa)) / Math.LN10;
            var shift:Number = Number(Math.floor(log10));

            mantissa /= Math.pow(10, shift);
            exponent += shift;

            // Fix rounding edge cases
            if (Math.abs(mantissa) >= 10)
            {
                mantissa /= 10;
                exponent++;
            }
            else if (Math.abs(mantissa) < 1)
            {
                mantissa *= 10;
                exponent--;
            }
        }

        // ➕ Addition
        public function add(other:BigDouble):BigDouble
        {
            if (mantissa == 0) return other.clone();
            if (other.mantissa == 0) return clone();

            var diff:Number = exponent - other.exponent;

            if (diff > 15) return clone();
            if (diff < -15) return other.clone();

            var resultMantissa:Number;

            if (diff >= 0)
            {
                resultMantissa = mantissa + other.mantissa * Math.pow(10, -diff);
                return new BigDouble(resultMantissa, exponent);
            }
            else
            {
                resultMantissa = mantissa * Math.pow(10, diff) + other.mantissa;
                return new BigDouble(resultMantissa, other.exponent);
            }
        }
        public function subtract(other:BigDouble):BigDouble
        {
            return this.add(new BigDouble(-other.mantissa, other.exponent));
        }
        public function divide(other:BigDouble):BigDouble
        {
            if (other.mantissa == 0)
                throw new Error("Division by zero");

            return new BigDouble(
                mantissa / other.mantissa,
                exponent - other.exponent
            );
        }
        public function pow(n:Number):BigDouble
        {
            if (mantissa == 0) return new BigDouble(0, 0);

            var log10:Number = this.log10();
            var resultLog:Number = log10 * n;

            var newExp:Number = Math.floor(resultLog);
            var newMan:Number = Math.pow(10, resultLog - newExp);

            return new BigDouble(newMan, newExp);
        }
        public function powBig(other:BigDouble):BigDouble
        {
            var resultLog:Number = this.log10() * other.toNumber();
            var newExp:Number = Math.floor(resultLog);
            var newMan:Number = Math.pow(10, resultLog - newExp);

            return new BigDouble(newMan, newExp);
        }
        public function toNumber():Number
        {
            return mantissa * Math.pow(10, exponent);
        }
        public function mod(other:BigDouble):BigDouble
        {
            var a:Number = this.toNumber();
            var b:Number = other.toNumber();

            if (!isFinite(a) || !isFinite(b))
                throw new Error("Modulo only works on small numbers");

            return BigDouble.fromNumber(a % b);
        }

        // ✖ Multiply
        public function multiply(other:BigDouble):BigDouble
        {
            return new BigDouble(
                mantissa * other.mantissa,
                exponent + other.exponent
            );
        }

        // 🔢 Multiply by number
        public function mul(n:Number):BigDouble
        {
            return new BigDouble(mantissa * n, exponent);
        }

        // 📊 log10 (VERY important for idle games)
        public function log10():Number
        {
            return exponent + Math.log(mantissa) / Math.LN10;
        }

        // ⚖ Compare
        public function greaterThan(other:BigDouble):Boolean
        {
            // Handle zero
            if (mantissa == 0) return false;
            if (other.mantissa == 0) return true;

            // Compare exponents first (fast path)
            if (exponent != other.exponent)
                return exponent > other.exponent;

            // Same exponent → compare mantissa
            return mantissa > other.mantissa;
        }
        public function lessThan(other:BigDouble):Boolean
        {
            return !this.equals(other) && !this.greaterThan(other);
        }
        public function greaterOrEqual(other:BigDouble):Boolean
        {
            return this.greaterThan(other) || this.equals(other);
        }
        public function lessOrEqual(other:BigDouble):Boolean
        {
            return this.lessThan(other) || this.equals(other);
        }
        public function equals(other:BigDouble):Boolean
        {
            if (mantissa == 0 && other.mantissa == 0) return true;

            return exponent == other.exponent && mantissa == other.mantissa;
        }
        public function clone():BigDouble
        {
            return new BigDouble(mantissa, exponent);
        }

        public function toString():String
        {
            return mantissa.toFixed(3) + "e" + exponent;
        }

        // 🧪 From Number
        public static function fromNumber(n:Number):BigDouble
        {
            if (n == 0) return new BigDouble(0, 0);

            var e:Number = Math.floor(Math.log(Math.abs(n)) / Math.LN10);
            var m:Number = n / Math.pow(10, e);

            return new BigDouble(m, e);
        }
    }
}