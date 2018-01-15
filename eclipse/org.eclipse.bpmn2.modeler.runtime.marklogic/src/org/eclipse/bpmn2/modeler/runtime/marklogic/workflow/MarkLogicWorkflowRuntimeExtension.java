/*******************************************************************************
 * Copyright (c) 2012 MarkLogic, Inc.
 *  All rights reserved.
 * This program is made available under the terms of the
 * Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 * MarkLogic, Inc. - initial API and implementation
 *
 * @author Adam Fowler
 ******************************************************************************/
package org.eclipse.bpmn2.modeler.runtime.marklogic.workflow;

//import java.net.MalformedURLException;
//import java.net.URL;
//import java.util.ArrayList;
//import java.util.HashMap;
//import java.util.Iterator;
//import java.util.LinkedHashMap;
//import java.util.List;
//import java.util.Map.Entry;

//import org.eclipse.bpmn2.Activity;
//import org.eclipse.bpmn2.DataInput;
//import org.eclipse.bpmn2.DataOutput;
//import org.eclipse.bpmn2.Event;
//import org.eclipse.bpmn2.Expression;
//import org.eclipse.bpmn2.Gateway;
//import org.eclipse.bpmn2.Interface;
//import org.eclipse.bpmn2.ItemDefinition;
//import org.eclipse.bpmn2.ManualTask;
//import org.eclipse.bpmn2.Message;
//import org.eclipse.bpmn2.MultiInstanceLoopCharacteristics;
//import org.eclipse.bpmn2.ReceiveTask;
//import org.eclipse.bpmn2.ScriptTask;
//import org.eclipse.bpmn2.SendTask;
//import org.eclipse.bpmn2.SequenceFlow;
//import org.eclipse.bpmn2.Task;
import org.eclipse.bpmn2.modeler.core.IBpmn2RuntimeExtension;
import org.eclipse.bpmn2.modeler.core.LifecycleEvent;
import org.eclipse.bpmn2.modeler.core.LifecycleEvent.EventType;
//import org.eclipse.bpmn2.modeler.core.merrimac.clad.PropertiesCompositeFactory;
//import org.eclipse.bpmn2.modeler.core.preferences.Bpmn2Preferences;
//import org.eclipse.bpmn2.modeler.core.runtime.CustomTaskDescriptor;
//import org.eclipse.bpmn2.modeler.core.runtime.CustomTaskImageProvider;
//import org.eclipse.bpmn2.modeler.core.runtime.ModelExtensionDescriptor.Property;
//import org.eclipse.bpmn2.modeler.core.runtime.TargetRuntime;
import org.eclipse.bpmn2.modeler.core.utils.ModelUtil.Bpmn2DiagramType;

import org.eclipse.bpmn2.modeler.ui.DefaultBpmn2RuntimeExtension.RootElementParser;
import org.eclipse.bpmn2.modeler.ui.editor.BPMN2Editor;
import org.eclipse.bpmn2.modeler.ui.wizards.FileService;
import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
//import org.eclipse.core.resources.IProject;
//import org.eclipse.core.resources.IResource;
//import org.eclipse.core.resources.IResourceVisitor;
//import org.eclipse.core.runtime.CoreException;
//import org.eclipse.core.runtime.Path;
import org.eclipse.emf.ecore.EObject;
//import org.eclipse.jface.dialogs.MessageDialog;
//import org.eclipse.jface.resource.ImageDescriptor;
//import org.eclipse.osgi.util.NLS;
//import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.IEditorInput;
import org.xml.sax.InputSource;

public class MarkLogicWorkflowRuntimeExtension implements IBpmn2RuntimeExtension {
	
	public final static String MLWF_RUNTIME_ID = "org.eclipse.bpmn2.modeler.runtime.marklogic.workflow"; //$NON-NLS-1$
	
	private static final String MLWF_NAMESPACE = "http://marklogic.com/workflow"; //$NON-NLS-1$
	
	/* (non-Javadoc)
	 * Check if the given input file is a ML WF-generated (WF) process file.
	 * 
	 * @see org.eclipse.bpmn2.modeler.core.IBpmn2RuntimeExtension#isContentForRuntime(org.eclipse.core.resources.IFile)
	 */
	@Override
	public boolean isContentForRuntime(IEditorInput input) {
		InputSource source = new InputSource( FileService.getInputContents(input) );
		RootElementParser parser = new RootElementParser(MLWF_NAMESPACE);
		parser.parse(source);
		return parser.getResult();
	}

	public String getTargetNamespace(Bpmn2DiagramType diagramType){
		return MLWF_NAMESPACE;
	}
	
	@Override
	public void notify(LifecycleEvent event) {
		if (event.eventType == EventType.EDITOR_INITIALIZED) {
			// Register all of our Property Tab Detail overrides here. 

	
			IFile inputFile = ((BPMN2Editor) event.target).getModelFile();
			if (inputFile!=null) {
				IContainer folder = inputFile.getParent();

				// TODO DO SOME NOTIFICATIONS
			}
		}
		else if (event.eventType == EventType.BUSINESSOBJECT_CREATED) {
			EObject object = (EObject) event.target;
			
			// TODO DO SOME NOTIFICATIONS
		}
	}
	
	
	
}
