/*******************************************************************************
 * Copyright (c) 2012 MarkLogic, Inc.
 * All rights reserved.
 * This program is made available under the terms of the
 * Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * 	MarkLogic, Inc. - initial API and implementation
 ******************************************************************************/
package org.eclipse.bpmn2.modeler.runtime.marklogic.workflow.wizards;

import org.eclipse.bpmn2.modeler.core.preferences.Bpmn2Preferences;
import org.eclipse.bpmn2.modeler.core.runtime.TargetRuntime;
//import org.eclipse.bpmn2.modeler.core.validation.SyntaxCheckerUtils;
import org.eclipse.bpmn2.modeler.runtime.marklogic.workflow.MarkLogicWorkflowRuntimeExtension;
import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IAdaptable;
import org.eclipse.core.runtime.Path;
import org.eclipse.jface.dialogs.IDialogPage;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.wizard.WizardPage;
import org.eclipse.osgi.util.NLS;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.ModifyEvent;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;
import org.eclipse.ui.dialogs.ContainerSelectionDialog;

/**
 * The "New" wizard page allows setting the container for the new file as well
 * as the file name. The page will only accept file name without the extension
 * OR with the extension that matches the expected one (bpmn).
 */

public class NewWorkflowProcessWizardPage1 extends WizardPage {
	private Text containerText;
	private Text fileText;
	private Text nameText;
	//private Text processIdText;
	//private Text packageText;
	private Button isWorkflowRuntimeCheckbox;
	private ISelection selection;

	/**
	 * Constructor for SampleNewWizardPage.
	 * 
	 * @param pageName
	 */
	public NewWorkflowProcessWizardPage1(ISelection selection) {
		super("wizardPage"); //$NON-NLS-1$
		setTitle(Messages.NewWorkflowProcessWizardPage1_Title);
		setDescription(Messages.NewWorkflowProcessWizardPage1_Description);
		this.selection = selection;
	}

	/**
	 * @see IDialogPage#createControl(Composite)
	 */
	public void createControl(Composite parent) {
		Composite container = new Composite(parent, SWT.NULL);
		GridLayout layout = new GridLayout();
		container.setLayout(layout);
		layout.numColumns = 3;
		layout.verticalSpacing = 9;
		Label label;
		GridData gridData;
		
		
		label = new Label(container, SWT.NULL);
		label.setText(Messages.NewWorkflowProcessWizardPage1_Process_Name);
		nameText = new Text(container, SWT.BORDER | SWT.SINGLE);
		gridData = new GridData(GridData.FILL, GridData.VERTICAL_ALIGN_BEGINNING, true, false, 2, 1);
		nameText.setLayoutData(gridData);
		nameText.addModifyListener(new ModifyListener() {
			public void modifyText(ModifyEvent e) {
				fileText.setText(nameText.getText() + ".bpmn2"); //$NON-NLS-1$
				//String processid = packageText.getText() + "." + nameText.getText(); //$NON-NLS-1$
				//processid = SyntaxCheckerUtils.toNCName(processid.replaceAll(" ", "_").replaceAll("-", "_")); //$NON-NLS-1$ //$NON-NLS-2$
				//processIdText.setText(processid);
				dialogChanged();
			}
		});
		
/*
		label = new Label(container, SWT.NULL);
		label.setText(Messages.NewWorkflowProcessWizardPage1_Package);
		packageText = new Text(container, SWT.BORDER | SWT.SINGLE);
		gridData = new GridData(GridData.FILL, GridData.VERTICAL_ALIGN_BEGINNING, true, false, 2, 1);
		packageText.setLayoutData(gridData);
		packageText.addModifyListener(new ModifyListener() {
			public void modifyText(ModifyEvent e) {
				String processid = packageText.getText() + "." + nameText.getText(); //$NON-NLS-1$
				processid = SyntaxCheckerUtils.toNCName(processid.replaceAll(" ", "_").replaceAll("-", "_")); //$NON-NLS-1$ //$NON-NLS-2$
				processIdText.setText(processid);
				dialogChanged();
			}
		});

		label = new Label(container, SWT.NULL);
		label.setText(Messages.NewWorkflowProcessWizardPage1_Process_ID);
		processIdText = new Text(container, SWT.BORDER | SWT.SINGLE);
		gridData = new GridData(GridData.FILL, GridData.VERTICAL_ALIGN_BEGINNING, true, false, 2, 1);
		processIdText.setLayoutData(gridData);
		processIdText.addModifyListener(new ModifyListener() {
			public void modifyText(ModifyEvent e) {
				dialogChanged();
			}
		});
		*/
		
		label = new Label(container, SWT.NULL);
		label.setText(Messages.NewWorkflowProcessWizardPage1_Container);
		containerText = new Text(container, SWT.BORDER | SWT.SINGLE);
		gridData = new GridData(GridData.FILL_HORIZONTAL);
		containerText.setLayoutData(gridData);
		containerText.addModifyListener(new ModifyListener() {
			public void modifyText(ModifyEvent e) {
				dialogChanged();
			}
		});

		Button button = new Button(container, SWT.PUSH);
		button.setText(Messages.NewWorkflowProcessWizardPage1_Browse);
		button.addSelectionListener(new SelectionAdapter() {
			public void widgetSelected(SelectionEvent e) {
				handleBrowse();
			}
		});
		label = new Label(container, SWT.NULL);
		label.setText(Messages.NewWorkflowProcessWizardPage1_File_Name);

		fileText = new Text(container, SWT.BORDER | SWT.SINGLE);
		gridData = new GridData(GridData.FILL, GridData.VERTICAL_ALIGN_BEGINNING, true, false, 2, 1);
		fileText.setLayoutData(gridData);
		fileText.addModifyListener(new ModifyListener() {
			public void modifyText(ModifyEvent e) {
				dialogChanged();
			}
		});
		
		isWorkflowRuntimeCheckbox = new Button(container, SWT.CHECK);
		isWorkflowRuntimeCheckbox.setText(Messages.NewWorkflowProcessWizardPage1_Set_Workflow_Default);
		isWorkflowRuntimeCheckbox.addSelectionListener(new SelectionAdapter() {
			public void widgetSelected(SelectionEvent e) {
				dialogChanged();
			}
		});
		gridData = new GridData(GridData.FILL, GridData.VERTICAL_ALIGN_BEGINNING, true, false, 3, 1);
		isWorkflowRuntimeCheckbox.setLayoutData(gridData);

		initialize();
		dialogChanged();
		setControl(container);
	}

	/**
	 * Tests if the current workbench selection is a suitable container to use.
	 */

	private void initialize() {
		IContainer container = null;
		if (selection != null && selection.isEmpty() == false
				&& selection instanceof IStructuredSelection) {
			IStructuredSelection ssel = (IStructuredSelection) selection;
			if (ssel.size() > 1)
				return;
			Object obj = ssel.getFirstElement();
			// The selected TreeElement could be a JavaProject, which is adaptable
			if (!(obj instanceof IResource) && obj instanceof IAdaptable) {
				obj = ((IAdaptable)obj).getAdapter(IResource.class);
			}
			if (obj instanceof IResource) {
				if (obj instanceof IContainer)
					container = (IContainer) obj;
				else
					container = ((IResource) obj).getParent();
				containerText.setText(container.getFullPath().toString());
			}
		}
		String basename = Messages.NewWorkflowProcessWizardPage1_Default_File_Name;
		String filename = basename + Messages.NewWorkflowProcessWizardPage1_BPMN_File_Extension;
		if (container!=null) {
			int i = 1;
			while (container.findMember(filename)!=null) {
				filename = basename + "_" + i + Messages.NewWorkflowProcessWizardPage1_BPMN_File_Extension; //$NON-NLS-1$
				++i;
			}
		}
		fileText.setText(filename);
		nameText.setText(Messages.NewWorkflowProcessWizardPage1_Default_Process_Name);
		//processIdText.setText(Messages.NewWorkflowProcessWizardPage1_Default_Process_ID);
		//packageText.setText(Messages.NewWorkflowProcessWizardPage1_Default_Package);
	}

	/**
	 * Uses the standard container selection dialog to choose the new value for
	 * the container field.
	 */

	private void handleBrowse() {
		ContainerSelectionDialog dialog = new ContainerSelectionDialog(
				getShell(), ResourcesPlugin.getWorkspace().getRoot(), false,
				Messages.NewWorkflowProcessWizardPage1_Browse_Title);
		if (dialog.open() == ContainerSelectionDialog.OK) {
			Object[] result = dialog.getResult();
			if (result.length == 1) {
				containerText.setText(((Path) result[0]).toString());
			}
		}
	}

	/**
	 * Ensures that both text fields are set.
	 */

	private void dialogChanged() {
		IResource container = ResourcesPlugin.getWorkspace().getRoot()
				.findMember(new Path(getContainerName()));
		String fileName = getFileName();

		if (getContainerName().length() == 0) {
			updateStatus(Messages.NewWorkflowProcessWizardPage1_Error_No_Container);
			return;
		}
		if (container == null
				|| (container.getType() & (IResource.PROJECT | IResource.FOLDER)) == 0) {
			updateStatus(Messages.NewWorkflowProcessWizardPage1_Error_Invalid_Container);
			return;
		}
		if (!container.isAccessible()) {
			updateStatus(Messages.NewWorkflowProcessWizardPage1_Error_Project_Readonly);
			return;
		}
		if (fileName.length() == 0) {
			updateStatus(Messages.NewWorkflowProcessWizardPage1_Error_No_File_Name);
			return;
		}
		if (fileName.replace('\\', '/').indexOf('/', 1) > 0) {
			updateStatus(Messages.NewWorkflowProcessWizardPage1_Error_Invalid_File_Name);
			return;
		}
		int dotLoc = fileName.lastIndexOf('.');
		if (dotLoc != -1) {
			String ext = fileName.substring(dotLoc + 1);
			if (!ext.equalsIgnoreCase("bpmn") && !ext.equalsIgnoreCase("bpmn2")) { //$NON-NLS-1$ //$NON-NLS-2$
				updateStatus(Messages.NewWorkflowProcessWizardPage1_Error_Invalid_File_Extension);
				return;
			}
			if ( ((IContainer)container).findMember(fileName)!=null ) {
				updateStatus(NLS.bind(Messages.NewWorkflowProcessWizardPage1_Error_File_Exists, fileName));
				return;
			}
		}
		/*
		String packageName = packageText.getText();
		if (!SyntaxCheckerUtils.isJavaPackageName(packageName)) {
			updateStatus(Messages.NewWorkflowProcessWizardPage1_Error_Package_Invalid);
			return;
		}
		String processId = processIdText.getText();
		if (!SyntaxCheckerUtils.isJavaPackageName(processId)) {
			updateStatus(Messages.NewWorkflowProcessWizardPage1_Error_Process_ID_Invalid);
			return;
		}*/
		
		String runtimeId = null;
		if (container instanceof IProject) {
			Bpmn2Preferences prefs = Bpmn2Preferences.getInstance((IProject)container);
			if (prefs!=null) {
				TargetRuntime rt = prefs.getRuntime();
				runtimeId = rt.getId();
			}						
		}
		if (MarkLogicWorkflowRuntimeExtension.MLWF_RUNTIME_ID.equals(runtimeId)) {
			isWorkflowRuntimeCheckbox.setSelection(true);
			isWorkflowRuntimeCheckbox.setEnabled(false);
		}
		else {
			isWorkflowRuntimeCheckbox.setSelection(true);
			isWorkflowRuntimeCheckbox.setEnabled(true);
		}

		updateStatus(null);
	}

	private void updateStatus(String message) {
		setErrorMessage(message);
		setPageComplete(message == null);
	}

	public IProject getProject() {
		IResource container = ResourcesPlugin.getWorkspace().getRoot()
				.findMember(new Path(getContainerName()));
		if (container instanceof IProject)
			return (IProject)container;
		return null;
	}
	
	public String getContainerName() {
		return containerText.getText();
	}

	public String getFileName() {
		return fileText.getText();
	}

	public String getProcessName() {
		return nameText.getText();
	}
/*
	public String getProcessId() {
		return processIdText.getText();
	}

	public String getPackageName() {
		return packageText.getText();
	}*/

	public boolean isSetWorkflowRuntime() {
		return isWorkflowRuntimeCheckbox.getSelection();
	}
}
