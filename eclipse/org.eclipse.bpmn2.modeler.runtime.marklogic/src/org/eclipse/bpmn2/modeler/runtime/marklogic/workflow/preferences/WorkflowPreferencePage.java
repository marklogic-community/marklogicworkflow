/*******************************************************************************
 * Copyright (c) 2012 MarkLogic, Inc.
 * All rights reserved.
 * This program is made available under the terms of the
 * Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * 	   MarkLogic, Inc. - initial API and implementation
 ******************************************************************************/
package org.eclipse.bpmn2.modeler.runtime.marklogic.workflow.preferences;

import org.eclipse.bpmn2.modeler.core.Activator;
import org.eclipse.bpmn2.modeler.core.preferences.Bpmn2Preferences;
import org.eclipse.jface.preference.BooleanFieldEditor;
import org.eclipse.jface.preference.FieldEditorPreferencePage;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPreferencePage;

public class WorkflowPreferencePage extends FieldEditorPreferencePage implements IWorkbenchPreferencePage {

	public WorkflowPreferencePage() {
		super(GRID);
		Bpmn2Preferences.getInstance();
		setPreferenceStore(Activator.getDefault().getPreferenceStore());
		setDescription(Messages.WorkflowPreferencePage_Workflow_Settings);
	}

	@Override
	public void init(IWorkbench workbench) {
	}

	@Override
	protected void createFieldEditors() {

		BooleanFieldEditor doCoreValidation = new BooleanFieldEditor(
				Bpmn2Preferences.PREF_DO_CORE_VALIDATION,
				Bpmn2Preferences.PREF_DO_CORE_VALIDATION_LABEL,
				getFieldEditorParent());
		addField(doCoreValidation);
	}
}
