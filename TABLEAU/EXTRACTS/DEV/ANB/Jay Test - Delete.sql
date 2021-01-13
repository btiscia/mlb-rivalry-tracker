Jay - 1/13/21


from ayx import Alteryx
import pandas as pd
import numpy as np

data_df = pd.DataFrame(Alteryx.read("#1"))

std_questions = ['estate', 'trust','viatical','collateral','pension','contestable']

Foreign_Death = ['did the death occur in the u.s.?:  no','insured-annuitant-country-of-residence-at-time-of-death: outside-of-the-united-states']


Divorce = ['was the deceased ever divorced?:  yes','insured-annuitant-marital-status-at-death: divorced',
           'insured marital status at the time of passing:  divorced']

CauseOfDeath = ['homicide','suicide','accident']

States = [' GA ', ' RI ',' VT ',' CA ',' MA ',' TX '] ## MM.com uses full state spelling...would require update if used in future. 
# Update ABR/LBR to look for spelled out words
ABR_LBR = [' ABR ', ' LBR ', 'accelerated','ABR/LBR']
# Add in viatical, collateral and contestable once we get more business insight
Guard_POA_Cust = ['guardian', 'poa', 'custodian','power of attorney']

answers = np.zeros([len(data_df['SourceTransactionID']),len(std_questions)+8])

for event in range(len(data_df['SourceTransactionID'])):
    for q in range(len(std_questions)):
        if std_questions[q].lower() in data_df['TXT_DES'].iloc[event].lower():
            answers[event,q +1] = 1
    if len([x for x in Foreign_Death if x in data_df['TXT_DES'].iloc[event].lower()]) > 0:
        answers[event,0] = 1   
    
    if len([x for x in Guard_POA_Cust if x in data_df['TXT_DES'].iloc[event].lower()]) > 0:
        answers[event,len(answers[event])-7] = 1       
    if len([x for x in Divorce if x in data_df['TXT_DES'].iloc[event].lower()]) > 0:
        answers[event,len(answers[event])-6] = 1
    if 'funeral' in data_df['TXT_DES'].iloc[event].lower() and 'funeral home information:  \n' not in data_df['TXT_DES'].iloc[event].lower():
        answers[event,len(answers[event])-5] = 1
    if len([x for x in CauseOfDeath if x in data_df['TXT_DES'].iloc[event].lower()]) > 0:
        answers[event,len(answers[event])-4] = 1
    #if len([x for x in CauseOfDeath if x in data_df['TXT_DES'].iloc[event].lower()]) > 0:
        #try:
            #codQuestion = 'cause of death:'
            #codIndex = data_df['TXT_DES'].iloc[event].lower().find(codQuestion)
            #codAnswer = 
        #except:
        #do something
    #else:
        #answers[event,len(answers[event])-5] = ''
    if len([x for x in States if x in data_df['TXT_DES'].iloc[event]]) > 0:
        answers[event,len(answers[event])-3] = 1
    if len([x for x in ABR_LBR if x in data_df['TXT_DES'].iloc[event]]) > 0:
        answers[event,len(answers[event])-2] = 1
    if 'split dollar' in data_df['TXT_DES'].iloc[event].lower() and 'split dollar:  no' not in data_df['TXT_DES'].iloc[event].lower():
        answers[event,len(answers[event])-1] = 1
 
answers = pd.DataFrame(answers)
answers.columns = ['Foreign Death','Estate','Trust','Viatical','Collateral','Pension','Contestable','Guard/POA/Cust','Divorce',
                'Funeral','Cause of Death','State-Comment','ABR/LBR','Split Dollar']
data = pd.concat([data_df,answers],axis=1)
Alteryx.write(data,1)
