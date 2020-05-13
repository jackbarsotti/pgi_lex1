public class Case_ConditionCheck {
public static boolean checkCondition(sObject objRec, Case_SLA_Exception_Rule_Conditions__c objOTRulecCrit){
		System.debug('objOTRulecCrit---->'+objOTRulecCrit);	
		String FieldApiName = objOTRulecCrit.Field_API_Name__c;
		System.debug('FieldApiName---->'+FieldApiName+ '------fieldType------>'+objOTRulecCrit.Field_Type__c);
		System.debug('objRec---->'+objRec);	

		// null check
		if(FieldApiName == null) {
			return false;
		}
		String recordValue = null;
		if(FieldApiName.contains('.')){
			String[] sliptFieldList = FieldApiName.split('\\.');
			System.debug('sliptFieldList---->'+sliptFieldList);	
			System.debug('sliptFieldList[1]---->'+sliptFieldList[1]);
			System.debug('sliptFieldList[0]---->'+sliptFieldList[0]);

			String sObjectName = sliptFieldList[0] == 'Owner'? 'User' : sliptFieldList[0];
			if(objRec.get(sliptFieldList[0]+'Id') == null){
				return false;
			}
			List<sObject> sObjRecord = Database.query('SELECT Id, '+sliptFieldList[1]+' FROM '+sObjectName+' WHERE Id =\''+objRec.get(sliptFieldList[0]+'Id')+'\'');
				System.debug('sObjRecord---->'+sObjRecord);
			recordValue = String.valueOf(sObjRecord[0].get(sliptFieldList[1]));
		}else{
			recordValue  = String.valueOf(objRec.get(FieldApiName));
		}
        System.debug('recordValue---->'+recordValue);	
        
		if(recordValue == null){
			return false;
		}
        String ruleValue = objOTRulecCrit.Field_Value__c;
        System.debug('ruleValue>>>>>>>>>> '+ruleValue);
		if(ruleValue == null){
			System.debug('ruleValue>>>>>>IFFFFFF>>>> '+ruleValue);
			return false;
		}
		// .toLowerCase() .toLowerCase()
		
		String fieldOperator =  objOTRulecCrit.Field_Operator__c;
		System.debug('fieldOperator>>>>> '+fieldOperator);
		String fieldType = objOTRulecCrit.Field_Type__c;
		System.debug('fieldType>>>>>>>>>>>> '+fieldType);
		if(fieldType.equalsIgnoreCase('BOOLEAN')){		
			//result = Boolean.valueOf(firstValue) == Boolean.valueOf(secondValue);
			if(fieldOperator.equalsIgnoreCase('equals')) {
				if(Boolean.valueOf(recordValue) == Boolean.valueOf(ruleValue)){
					return true;
				}			
			}else if(fieldOperator.equalsIgnoreCase('notEqual')){
				if(Boolean.valueOf(recordValue) != Boolean.valueOf(ruleValue)){
					return true;
				}	
			} 
		}else if(fieldType.equalsIgnoreCase('TEXTAREA') 		|| 
				fieldType.equalsIgnoreCase('TEXT') 				|| 
				fieldType.equalsIgnoreCase('PICKLIST')			||
				fieldType.equalsIgnoreCase('EMAIL') 			||
				fieldType.equalsIgnoreCase('URL') 				||
				fieldType.equalsIgnoreCase('STRING')  			|| 
				fieldType.equalsIgnoreCase('COMBOBOX') 			|| 
				fieldType.equalsIgnoreCase('ENCRYPTEDSTRING')	||
				fieldType.equalsIgnoreCase('MULTIPICKLIST') 	|| 
				fieldType.equalsIgnoreCase('REFERENCE')         ||
				fieldType.equalsIgnoreCase('PHONE') ){
			
				
				System.debug(recordValue+' '+fieldOperator+' '+ruleValue);
				if(fieldOperator.equals('equals') ){
					// if(recordValue == ruleValue || recordValue.equals(ruleValue)){
					// 	return true;
					// }
					if(ruleValue.equalsIgnoreCase(recordValue) || recordValue.equalsIgnoreCase(ruleValue)){
						return true;
					}

				} else if(fieldOperator.equals('notEqual')){
					// if(recordValue <> ruleValue ||  !recordValue.equals(ruleValue)){
					// 	return true;
					// }
					if(!ruleValue.equalsIgnoreCase(recordValue) || !recordValue.equalsIgnoreCase(ruleValue)){
						return true;
					}
					
				} else if(fieldOperator.equals('lessThan')){
					if(recordValue < ruleValue){
						return true;
					}
					
				} else if(fieldOperator.equals('greaterThan')){
					if(recordValue > ruleValue){
						return true;
					} 
					
				} else if(fieldOperator.equals('lessOrEqual')){
					if(recordValue <= ruleValue){
						return true;
					}
					// Test it for date Fieldtype
				} else if(fieldOperator.equals('greaterOrEqual')){
					if(recordValue >= ruleValue){
						return true;
					}
					// Test it for date Fieldtype
				} else if(fieldOperator.equals('contains')){
					if(ruleValue.containsIgnoreCase(recordValue) || recordValue.containsIgnoreCase(ruleValue)){
						return true;
					}
					
				} else if(fieldOperator.equals('doesnotcontains')){
					if(!ruleValue.containsIgnoreCase(recordValue) || !recordValue.containsIgnoreCase(ruleValue)){
						return true;
					}
					
				// } else if(fieldOperator.equals('startsWith')){
				// 	if(ruleValue.containsIgnoreCase(recordValue) || recordValue.containsIgnoreCase(ruleValue)){
				// 		return true;
				// 	}
				} else if(fieldOperator.equals('startsWith')){
					// if(ruleValue.startsWith(recordValue) || recordValue.startsWith(ruleValue)){
					// 	return true;
					// }
					if(ruleValue.containsIgnoreCase(recordValue) || recordValue.containsIgnoreCase(ruleValue)){
						return true;
					}
				} else if(fieldOperator.equals('includes')){
					if(ruleValue.containsIgnoreCase(recordValue) || recordValue.containsIgnoreCase(ruleValue)){
						return true;
					}
				} else if(fieldOperator.equals('excludes')){
				if(!ruleValue.containsIgnoreCase(recordValue) || !recordValue.containsIgnoreCase(ruleValue)){
						return true;
					}          
				}
			
		}else if(fieldType.equalsIgnoreCase('DATE')){
			Date recDateVal = Date.valueOf(recordValue);
			Date ruleDateVal = Date.valueOf(ruleValue);

			if(fieldOperator.equals('equals') ){           
				if(recDateVal == ruleDateVal ){
					return true;
				}

			} else if(fieldOperator.equals('notEqual')){
				if(recDateVal <> ruleDateVal ){
					return true;
				}
				
			} else if(fieldOperator.equals('lessThan')){
				if(recDateVal < ruleDateVal){
					return true;
				}
				
			} else if(fieldOperator.equals('greaterThan')){
				if(recDateVal > ruleDateVal){
					return true;
				} 
				
			} else if(fieldOperator.equals('lessOrEqual')){
				if(recDateVal <= ruleDateVal){
					return true;
				}
				// Test it for date Fieldtype
			} else if(fieldOperator.equals('greaterOrEqual')){
				if(recDateVal >= ruleDateVal){
					return true;
				}
			}
		}else if((fieldType.equalsIgnoreCase('INTEGER')) || 
				(fieldType.equalsIgnoreCase('NUMBER')) || 
				fieldType.equalsIgnoreCase('CURRENCY') ){
			INTEGER recordValConverted = INTEGER.valueOf(recordValue);
			INTEGER ruleValConverted = INTEGER.valueOf(ruleValue);

			if(fieldOperator.equals('equals') ){           
				if(recordValConverted == ruleValConverted ){
					return true;
				}

			} else if(fieldOperator.equals('notEqual')){

				if(recordValConverted <> ruleValConverted ){
					return true;
				}
				
			} else if(fieldOperator.equals('lessThan')){
				if(recordValConverted < ruleValConverted){
					return true;
				}
				
			} else if(fieldOperator.equals('greaterThan')){
				if(recordValConverted > ruleValConverted){
					return true;
				} 
				
			} else if(fieldOperator.equals('lessOrEqual')){
				if(recordValConverted <= ruleValConverted){
					return true;
				}
				// Test it for date Fieldtype
			} else if(fieldOperator.equals('greaterOrEqual')){
				if(recordValConverted >= ruleValConverted){
					return true;
				}
			}
		}else if(fieldType.equalsIgnoreCase('DATETIME') ){
			DATETIME recordValConverted = DATETIME.valueOf(recordValue);
			DATETIME ruleValConverted = DATETIME.valueOf(ruleValue);

			if(fieldOperator.equals('equals') ){           
				if(recordValConverted == ruleValConverted ){
					return true;
				}

			} else if(fieldOperator.equals('notEqual')){
				if(recordValConverted <> ruleValConverted ){
					return true;
				}
				
			} else if(fieldOperator.equals('lessThan')){
				if(recordValConverted < ruleValConverted){
					return true;
				}
				
			} else if(fieldOperator.equals('greaterThan')){
				if(recordValConverted > ruleValConverted){
					return true;
				} 
				
			} else if(fieldOperator.equals('lessOrEqual')){
				if(recordValConverted <= ruleValConverted){
					return true;
				}
				// Test it for date Fieldtype
			} else if(fieldOperator.equals('greaterOrEqual')){
				if(recordValConverted >= ruleValConverted){
					return true;
				}
			}
		}else if(fieldType.equalsIgnoreCase('PERCENT') || (fieldType.equalsIgnoreCase('DOUBLE'))){
			DOUBLE recordValConverted = DOUBLE.valueOf(recordValue);
			DOUBLE ruleValConverted = DOUBLE.valueOf(ruleValue);

			if(fieldOperator.equals('equals') ){           
				if(recordValConverted == ruleValConverted ){
					return true;
				}

			} else if(fieldOperator.equals('notEqual')){
				if(recordValConverted <> ruleValConverted ){
					return true;
				}
				
			} else if(fieldOperator.equals('lessThan')){
				if(recordValConverted < ruleValConverted){
					return true;
				}
				
			} else if(fieldOperator.equals('greaterThan')){
				if(recordValConverted > ruleValConverted){
					return true;
				} 
				
			} else if(fieldOperator.equals('lessOrEqual')){
				if(recordValConverted <= ruleValConverted){
					return true;
				}
				// Test it for date Fieldtype
			} else if(fieldOperator.equals('greaterOrEqual')){
				if(recordValConverted >= ruleValConverted){
					return true;
				}
			}
		}
		return false;
	}
}