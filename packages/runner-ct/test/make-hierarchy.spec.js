const { makeSpecHierarchy } = require('../src/specs/make-hierarchy')
const { expect } = require('chai')

const folderSpec = {
  name: 'make-dir/foo.spec.js'
}

const fileSpec = {
  name: 'foo.spec.js'
}

const nameSpec = {
  name: 'name/foo.spec.js'
}

describe('makeSpecHierarchy', () => {
  it('works for folders', () => {
    const finalSpecs = [{
      name: 'make-dir',
      type: 'folder',
      specs: [
        {
          name: 'bar',
          type: 'folder',
          specs: [
            {
              name: 'foo.spec.js',
              type: 'file'
            }
          ]
        }
      ]
    }]

    const specs = makeSpecHierarchy([{ name: 'make-dir/bar/foo.spec.js' }])

    expect(specs).to.eqls(finalSpecs)
  })

  it('works for multi hirachy folders', () => {
    const finalSpecs = [{
      name: 'make-dir',
      type: 'folder',
      specs: [
        {
          type: 'file',
          name: 'qux.spec.js'
        },
        {
          name: 'bar',
          type: 'folder',
          specs: [
            {
              name: 'foo.spec.js',
              type: 'file'
            },
            {
              name: 'baz.spec.js',
              type: 'file'
            }
          ]
        }
      ]
    }]

    const specs = makeSpecHierarchy([
      { name: 'make-dir/bar/foo.spec.js' },
      { name: 'make-dir/bar/baz.spec.js' }
    ])

    expect(specs).to.eqls(finalSpecs)
  })

  it('works for files', () => {
    const specs = makeSpecHierarchy([fileSpec])

    expect(specs).to.eqls([
      { name: 'foo.spec.js', type: 'file' }
    ])
  })
})
