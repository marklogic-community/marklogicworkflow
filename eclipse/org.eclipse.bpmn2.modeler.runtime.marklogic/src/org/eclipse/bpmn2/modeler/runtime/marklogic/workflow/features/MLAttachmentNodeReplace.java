package org.eclipse.bpmn2.modeler.runtime.marklogic.workflow.features;

import org.eclipse.bpmn2.modeler.core.features.CustomShapeFeatureContainer;
import org.eclipse.bpmn2.modeler.core.features.ShowPropertiesFeature;
import org.eclipse.bpmn2.modeler.core.model.ModelDecorator;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.graphiti.features.custom.ICustomFeature;


public class MLAttachmentNodeReplace extends CustomShapeFeatureContainer {


	  // these values must match what's in the plugin.xml
	  private final static String TYPE_VALUE = "MLAttachmentNodeReplace";
	  private final static String CUSTOM_TASK_ID = "MLAttachmentNodeReplace.customTask";

	  public MLAttachmentNodeReplace() { 
	  }

	  @Override
	  public String getId(EObject object) {
		// This is where we inspect the object to determine what its custom task ID should be.
		// In this case, the "type" attribute will have a value of "MyTask".
		// If found, return the CUSTOM_TASK_ID string.
		//
		// Note that the object inspection can be arbitrarily complex and may include several
		// object features. This simple case just demonstrates what needs to happen here.
		EStructuralFeature f = ModelDecorator.getAnyAttribute(object, "type");
		if (null != f) {
		  Object id = object.eGet(f);
		  if (TYPE_VALUE.equals(id)) {
		    return CUSTOM_TASK_ID;
		  }
		}
		 
		return null;
	  }


	  @Override
	  public ICustomFeature[] getCustomFeatures(IFeatureProvider fp) {
		return new ICustomFeature[] {
		  new ShowPropertiesFeature(fp)
		};
	  }
}
