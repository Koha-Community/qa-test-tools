INSERT INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
('AcqCreateItem','ordering','ordering|receiving|cataloguing','Define when the item is created : when ordering, when receiving, or in cataloguing module','Choice'),
('BorrowerMandatoryField','surname|cardnumber',NULL,'Choose the mandatory fields for a patron\'s account','free'),
('viewMARC','1','','Allow display of MARC view of bibiographic records','YesNo'),
('CircAutocompl','1',NULL,'If ON, autocompletion is enabled for the Circulation input','YesNo'),
('displayFacetCount','0',NULL,NULL,'YesNo')
;
