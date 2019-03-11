from guardian import GuardState
import time

## FUNCTIONS

def adj_rh_power(power_adj):
    ezca['SETUPPERPOWER'] = power_adj
    ezca['SETLOWERPOWER'] = power_adj

## insert error checker


 ## STATES ##

nominal = 'NOMINAL'

class NOMINAL(GuardState):
    index = 1
    goto = True
    def main(self):
        self.timer['wait'] = 0.0
        ezca['INVERSE_FILTER_MASK'] = 1

    def run(self):
        if self.timer['wait'] :
            ezca['INVERSE_INVERSE_FILTER_IN'] = ezca['SETLOWERPOWER']
            self.timer['wait'] = 1.0
        return True


class FILTER_RH_INPUT(GuardState):
    index = 2
    def main(self):
       self.timer['wait'] = 0.0
       ezca['INVERSE_FILTER_MASK'] = 0
       log('Adjusting the RH power')

    def run(self):
        if self.timer['wait'] :
           self.RECENT_FILTER_REQUEST = ezca['INVERSE_FILTER_OUTVAL']
           if (self.RECENT_FILTER_REQUEST) < 0:
               log('RH attempting to go to negative power')
               self.RECENT_FILTER_REQUEST = 0.0
           adj_rh_power(self.RECENT_FILTER_REQUEST)
           ezca['INVERSE_FILTER_IN'] = self.RECENT_FILTER_REQUEST
           #log('{}'.format(ezca['INVERSE_FILTER_OUTVAL']))
           self.timer['wait'] = 1.0
        return True


class RESET(GuardState):
    index = 3
    def main(self):
        self.state = ezca['INVERSE_FILTER_MASK']
        if self.state > 0 :
            # we are in nominal state
            self.val = ezca['SETUPPERPOWER']
            ezca['INVERSE_INVERSE_FILTER_IN'] = self.val
            ezca['PRIORVAL'] = self.val
            time.sleep(0.1)
            ezca['INVERSE_INVERSE_FILTER_RSET'] = 2
            time.sleep(0.1)
            ezca['INVERSE_FILTER_RSET'] = 2
            return True 
          
        else:
            # we are in filter RH  state
            self.val = ezca['INVERSE_FILTER_IN']
            ezca['PRIORVAL'] = self.val
            ezca['INVERSE_INVERSE_FILTER_IN'] = self.val
            time.sleep(0.1)
            ezca['INVERSE_FILTER_RSET'] = 2            
            ezca['INVERSE_INVERSE_FILTER_RSET'] = 2   
            return True        



edges = [('INIT', 'NOMINAL'),
         ('NOMINAL', 'INIT'),
         ('FILTER_RH_INPUT', 'NOMINAL'),
         ('NOMINAL', 'FILTER_RH_INPUT'),   
         ('RESET', 'NOMINAL'),
         ('NOMINAL', 'RESET'), 
         ('RESET', 'FILTER_RH_INPUT'), 
         ('FILTER_RH_INPUT', 'RESET')]
