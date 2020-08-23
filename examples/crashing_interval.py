import sollya
from sollya import Interval

interval = Interval(-0.01, 100)

sollya.settings.prec = 165

new_range_lo = sollya.floor(sollya.log2(sollya.inf(abs(interval))))
new_range_hi = sollya.ceil(sollya.log2(sollya.sup(abs(interval))))

new_range = Interval(new_range_lo, new_range_lo)
print("new_range = {}".format(new_range))
